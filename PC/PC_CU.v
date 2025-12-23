module PC_CU (
    input clk,
    input reset,
    input intr,
    input   [3:0]  opcode,
    input   [1:0]  brx,
    input  branch_taken,
    input  bypass_decode_done,
    output reg         pc_en,
    output reg         pc_load,
    output reg         stall,
    output reg [1:0]   counter,
    output reg [1:0]   pc_src,
    output reg [1:0]   addr_src    
);
localparam    
    S_RESET_INTER = 3'd0,
    S_FETCH1 = 3'd1,
    S_FETCH2 = 3'd2,
    S_WAIT   = 3'd3,
    S_BRANCH   = 3'd4;

reg [2:0] state, next_state;
reg two_byte;
reg pc_was_loaded;  // Track if PC was loaded in previous state

always @(*) begin
    two_byte = (opcode == 4'd12); // LDM, LDD, STD
end

always @(posedge clk) begin
    if (intr)
        state <= S_RESET_INTER;
        else if (reset)
        state <= S_RESET_INTER;
    else
        state <= next_state;
end

// Track if PC was loaded (for branches, jumps, etc.)
always @(posedge clk) begin
    if (reset)
        pc_was_loaded <= 1'b1;  // Reset loads PC
    else if (intr)
        pc_was_loaded <= 1'b1;  // Interrupt loads PC
    else if (branch_taken)  // Conditional branch taken or LOOP taken
            pc_was_loaded <= 1'b1;
        else if (opcode == 4'd11)  // JMP, CALL, RET, RTI
            pc_was_loaded <= 1'b1;
        else
            pc_was_loaded <= 1'b0;
end

always @(*) begin
    // defaults
    pc_en      = 0;
    pc_load    = 0;
    pc_src     = 2'b00;
    addr_src   = 2'b00;
    stall      = 0;
    counter    = 2'b00;
    next_state = state;

    case (state)
    // ===== RESET OR INTERRUPT =====
    S_RESET_INTER: begin
       if (intr) begin
            pc_en   = 1;
            pc_load = 1;
            pc_src  = 2'b01;   // I_out
            addr_src = 2'b10; // M[1]
        end
        else begin
            if (reset) begin
        pc_en   = 1;
        pc_load = 1;
        pc_src  = 2'b01;   // I_out
        addr_src = 2'b01; // M[0]
            end
        end
    if (!intr && !reset)  
        next_state = S_FETCH1;
        else 
        next_state = S_RESET_INTER;
    end
    // ===== FETCH =====
    S_FETCH1: begin
        // Only increment PC if it wasn't just loaded
        if (!pc_was_loaded) begin
            pc_en = 1;
        end
        addr_src = 2'b00; // normal fetch

        if (two_byte)
            next_state = S_FETCH2;
        else if (branch_taken || (opcode == 4'd11 && brx < 2)) // Loop taken or JZ , JC , JV , JN taken or JMP/CALL
            next_state = S_BRANCH;
        else if (opcode == 4'd11 && brx >= 2) // RET/RTI
            next_state = S_WAIT;
        else
            next_state = S_FETCH1;
    end

    // ===== FETCH IMM / EA =====
    S_FETCH2: begin
        pc_en    = 1;
        next_state = S_FETCH1;
    end
    // ===== WAIT STATE FOR MEM OPS =====
    S_WAIT: begin
        // Simple 2-cycle wait for memory (for RET/RTI)
        if (counter < 2'b10) begin
            counter = counter + 1;
            stall = 1;  // Stall Pipeline while waiting for memory
            next_state = S_WAIT;
        end
        else  if (counter == 2'b10) begin
            stall = 0;
            counter = 2'b00;
            next_state = S_BRANCH;
        end

    end

    // ===== PC DECISION =====
    S_BRANCH: begin
        // ----- Conditional Branches & LOOP -----
            if (branch_taken) begin
                pc_load = 1;
                pc_en = 1;
                pc_src  = 2'b00; // R[rb]ex
            end

        // ----- JMP / CALL -----
        else if (opcode == 4'd11 && brx < 2) begin
            wait(bypass_decode_done);
            pc_load = 1;
            pc_en = 1;
            pc_src  = 2'b10; // R[rb]d
        end

        // ----- RET / RTI -----
        else if (opcode == 4'd11 && brx >= 2) begin
            pc_load = 1;
            pc_en = 1;
            pc_src  = 2'b11; // data_out
        end
        next_state = S_FETCH1;
    end

    endcase
end

endmodule