module Fetch_Stage_CU (
    input clk,
    input reset,
    input intr,
    input stall_in,
    input   [3:0]  opcode,
    input   [1:0]  brx,
    input  branch_taken,
    input  bypass_decode_done,  // 1 = Bypass from Decode stage is done or no bypass needed , 0 = Bypass not done yet
    output reg         pc_en,
    output reg         pc_load,
    output reg         stall,
    output reg         sf1, // 0 always (inst data) , 1 Int (pc)
    output reg [1:0]   pc_src,
    output reg [1:0]   addr_src,
    output reg         int_clr    
);

localparam  S_RESET_INTER = 3'd0,
            S_FETCH1 = 3'd1,
            S_FETCH2 = 3'd2,
            S_WAIT   = 3'd3,
            S_BRANCH = 3'd4;

reg [1:0]   counter;
reg [2:0] state, next_state;
reg two_byte;
reg pc_was_loaded;  // Track if PC was loaded in previous state

always @(*) begin
    two_byte = (opcode == 4'd12); // LDM, LDD, STD
end

always @(posedge clk or negedge reset) begin
    if (intr || !reset)
        state <= S_RESET_INTER;
    else
        state <= next_state;
end

// Track if PC was loaded (for branches, jumps, etc.)
always @(posedge clk or negedge reset) begin
    if (!reset || intr)
        pc_was_loaded <= 1'b1;
    else
        pc_was_loaded <= 1'b0;
end

// counter for wait state
always @(posedge clk or negedge reset) begin
    if (!reset || intr) 
        counter <= 2'b00;
    else
    if (state == S_WAIT &! stall_in)
        counter <= counter + 1;
    else if (state == S_WAIT && stall_in)
        counter <= counter;
    else 
        counter <= 2'b00;
end

always @(*) begin
    // defaults
    pc_en      = 0;
    pc_load    = 0;
    pc_src     = 2'b00;
    addr_src   = 2'b00;
    stall      = 0;
    next_state = state;
    sf1        = 1'b0;
    int_clr    = 1'b0;

    case (state)
    // ===== RESET OR INTERRUPT =====
    S_RESET_INTER: begin
        pc_en   = 1;
        if (!reset) begin
                pc_load = 1;
                pc_src  = 2'b01;   // I_out
                addr_src = 2'b01; // M[0]
            end
        else if (intr) begin
            pc_load  = 1;
            pc_src   = 2'b01;   // I_out
            addr_src = 2'b10; // M[1]
            sf1      = 1'b1;
            int_clr  = 1'b1;
        end

        if (!intr && reset)  
            next_state = S_FETCH1;
        else 
            next_state = S_RESET_INTER;
    end
    // ===== FETCH =====
    S_FETCH1: begin
        // ----- Conditional Branches & LOOP -----
        if (branch_taken) begin //!
            pc_load = 1;
            pc_en = 1;
            pc_src  = 2'b00; // R[rb]ex
            next_state = S_FETCH1;
        end
        // ----- RET / RTI -----
        else if (opcode == 4'd11 && brx >= 2) begin //!
            pc_load = 1;
            pc_en = 1;
            pc_src  = 2'b11; // data_out
            next_state = S_FETCH1;
        end
        // ----- JMP / CALL -----
        else if (opcode == 4'd11 && brx < 2) begin 
            if(bypass_decode_done) begin
                pc_load = 1;
                pc_en = 1;
                pc_src  = 2'b10; // R[rb]d
                next_state = S_FETCH1;
            end
            else begin // bypass not done, stall
                stall = 1'b1;
                next_state = S_FETCH1;
            end
        end else begin
            // Only increment PC if it wasn't just loaded

            if (!pc_was_loaded) begin
                pc_en = 1;
            end
            addr_src = 2'b00; // normal fetch

            if (two_byte)
                next_state = S_FETCH2;
            else if (branch_taken || (opcode == 4'd11 && brx < 2)) // Loop taken or JZ , JC , JV , JN taken or JMP/CALL
                next_state = S_FETCH1;
            else if (opcode == 4'd11 && brx >= 2) // RET/RTI
                next_state = S_WAIT;
            else
                next_state = S_FETCH1;
            
        end
    end

    // ===== FETCH IMM / EA =====
    S_FETCH2: begin
        pc_en    = 1;
        next_state = S_FETCH1;
    end
    // ===== WAIT STATE FOR MEM OPS =====
    S_WAIT: begin
        // Simple 2-cycle wait for memory (for RET/RTI)
        stall = 1'b1;
        if (counter == 2'b10) begin
            stall      = 1'b0;
            next_state = S_FETCH1;
        end
        else begin
            next_state = S_WAIT;
        end

    end
    default: begin
        pc_en      = 0;
        pc_load    = 0;
        pc_src     = 2'b00;
        addr_src   = 2'b00;
        stall      = 0;
        next_state = state;
        sf1        = 1'b0;
        int_clr    = 1'b0;
    end

    endcase
end

endmodule