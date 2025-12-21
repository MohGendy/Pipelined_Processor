/* Module: Branch Unit
Description: 
    Controls the program flow by generating a 'flush' signal (which also acts as branch taken).
    It checks conditions based on stored Flags (CCR) or current ALU status (Znow).

Inputs:
    - bu_op (3 bits): Control signal from CU determining the branch type.
    - flags (4 bits): From CCR Register [V, C, N, Z] (Previous Instruction status).
    - z_now (1 bit):  From ALU directly (Current Instruction status for LOOP).

Output:
    - flush (1 bit): Active High. 
      If 1: Branch condition met -> Flush pipeline & Load Branch Address to PC.
      If 0: No Branch -> Continue sequential execution (PC + 1).
*/

module branch_unit (
    input  wire [2:0] bu_op,    // Branch Unit Opcode from Control Unit
    input  wire [3:0] flags,    // CCR Output: {V, C, N, Z} -> See Mapping below
    input  wire       z_now,    // Current Zero Flag from ALU (Used for LOOP)
    output reg        flush     // 1 = Branch Taken (Flush Pipeline), 0 = Not Taken
);

    // Flag Mapping
    // Z = bit 0, N = bit 1, C = bit 2, V = bit 3
    wire z_flag;
    wire n_flag;
    wire c_flag;
    wire v_flag;

    assign z_flag = flags[0];
    assign n_flag = flags[1];
    assign c_flag = flags[2];
    assign v_flag = flags[3];

    // Branch Logic
    always @(*) begin
        case (bu_op)
            // 000: No Operation / Normal Instruction (No Branch)
            3'b000: flush = 1'b0; 

            // 001: JZ (Jump if Zero) -> Check stored Z flag 
            3'b001: flush = z_flag; 

            // 010: JN (Jump if Negative) -> Check stored N flag 
            3'b010: flush = n_flag; 

            // 011: JC (Jump if Carry) -> Check stored C flag 
            3'b011: flush = c_flag; 

            // 100: JV (Jump if Overflow) -> Check stored V flag 
            3'b100: flush = v_flag; 

            // 101: LOOP Instruction 
            // Description: R[ra] = R[ra] - 1. If result != 0, Branch (Jump to label).
            // Logic: If ALU result is NOT Zero (z_now == 0), we loop (flush = 1).
            //        If ALU result IS Zero (z_now == 1), loop finishes (flush = 0).
            3'b101: flush = ~z_now; 

            // Default case
            default: flush = 1'b0;
        endcase
    end

endmodule