/* Control Unit - Branch Opcode Decoder
   Description: Generates the 'bu_op' signal for the Branch Unit 
   based on the Instruction Opcode and Ra field.
*/

module control_unit_branch_logic (
    input  wire [3:0] opcode,  // Opcode from Instruction [7:4]
    input  wire [1:0] ra,      // Ra field from Instruction [3:2] (Used for conditions)
    output reg  [2:0] bu_op    // Output to Branch Unit
);

    always @(*) begin
        // Default value: 000 (No Branching Action)
        bu_op = 3'b000;

        case (opcode)

            // Case 1: Conditional Jumps (Opcode = 9 / 4'b1001)

            // Here we look at 'ra' to know which flag to check
            4'b1001: begin
                case (ra)
                    2'b00: bu_op = 3'b001; // JZ (Jump Zero)
                    2'b01: bu_op = 3'b010; // JN (Jump Negative)
                    2'b10: bu_op = 3'b011; // JC (Jump Carry)
                    2'b11: bu_op = 3'b100; // JV (Jump Overflow)
                    default: bu_op = 3'b000;
                endcase
            end


            // Case 2: Loop Instruction (Opcode = 10 / 4'b1010)

            4'b1010: begin
                bu_op = 3'b101; // LOOP
            end
            // Default for all other instructions (ADD, SUB, LD, etc.)
            default: begin
                bu_op = 3'b000;
            end
        endcase
    end

endmodule