module PC_CU (
    input clk,
    input reset,
    input intr,
    input   [3:0]  opcode,
    input   [1:0]  brx,
    input  Z_flag,
    input  N_flag,
    input  C_flag,
    input  V_flag,
    output reg         pc_en,
    output reg         pc_load,
    output reg         byte_sel,
    output reg         if_en,
    output reg         instr_done,
    output reg [1:0]   pc_src,
    output reg [1:0]   addr_src    
);
localparam    
    S_RESET  = 2'd0,
    S_FETCH1 = 2'd1,
    S_FETCH2 = 2'd2,
    S_DONE   = 2'd3;

reg [1:0] state, next_state;
reg two_byte;
reg branch_taken;
reg pc_was_loaded;  // Track if PC was loaded in previous state

always @(*) begin
    two_byte = (opcode == 4'd12); // LDM, LDD, STD
end

always @(*) begin
    branch_taken = 1'b0;
    if (opcode == 4'd9) begin
        case (brx)
            2'd0: branch_taken = Z_flag; // JZ
            2'd1: branch_taken = N_flag; // JN
            2'd2: branch_taken = C_flag; // JC
            2'd3: branch_taken = V_flag; // JV
        endcase
    end
end

always @(posedge clk) begin
    if (reset)
        state <= S_RESET;
    else
        state <= next_state;
end

// Track if PC was loaded (for branches, jumps, etc.)
always @(posedge clk) begin
    if (reset)
        pc_was_loaded <= 1'b1;  // Reset loads PC
    else if (intr)
        pc_was_loaded <= 1'b1;  // Interrupt loads PC
    else if (state == S_DONE) begin
        // Check if any control flow instruction loaded PC
        if (opcode == 4'd9 && branch_taken)  // Conditional branch taken
            pc_was_loaded <= 1'b1;
        else if (opcode == 4'd10 && !Z_flag)  // LOOP taken
            pc_was_loaded <= 1'b1;
        else if (opcode == 4'd11)  // JMP, CALL, RET, RTI
            pc_was_loaded <= 1'b1;
        else
            pc_was_loaded <= 1'b0;
    end
    else
        pc_was_loaded <= 1'b0;
end

always @(*) begin
    // defaults
    pc_en      = 0;
    pc_load    = 0;
    byte_sel   = 0;
    if_en      = 0;
    instr_done = 0;
    pc_src     = 2'b00;
    addr_src   = 2'b00;
    next_state = state;

    case (state)
    // ===== RESET =====
    S_RESET: begin
        pc_en   = 1;
        pc_load = 1;
        pc_src  = 2'b01;   // I_out
        if_en   = 1;
        addr_src = 2'b01; // M[0]
    if (!reset)  
        next_state = S_FETCH1;
    else
        next_state = S_RESET;
    end
    // ===== FETCH =====
    S_FETCH1: begin
        // Only increment PC if it wasn't just loaded
        if (!pc_was_loaded) begin
            pc_en = 1;
        end
        if_en = 1;
        addr_src = 2'b00; // normal fetch

        if (two_byte)
            next_state = S_FETCH2;
        else
            next_state = S_DONE;
    end

    // ===== FETCH IMM / EA =====
    S_FETCH2: begin
        pc_en    = 1;
        if_en    = 1;
        byte_sel = 1;
        next_state = S_DONE;
    end

    // ===== EXECUTE / PC DECISION =====
    S_DONE: begin
        instr_done = 1;
        if (intr) begin
            pc_en   = 1;
            pc_load = 1;
            pc_src  = 2'b01;   // I_out
            addr_src = 2'b10; // M[1]
        end

        // ----- Conditional Branches -----
        else if (opcode == 4'd9) begin
            if (branch_taken) begin
                pc_load = 1;
                pc_en = 1;
                pc_src  = 2'b00; // R[rb]ex
            end
        end

        // ----- LOOP -----
        else if (opcode == 4'd10) begin
            if (!Z_flag) begin
                pc_load = 1;
                pc_en = 1;
                pc_src  = 2'b00; // R[rb]ex
            end
        end

        // ----- JMP / CALL -----
        else if (opcode == 4'd11 && brx < 2) begin
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
	if(intr)
        next_state = S_DONE;
	else
        next_state = S_FETCH1;
    end

    endcase
end

endmodule
