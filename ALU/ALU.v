module ALU (
    input CLK,
    input [7:0] A,
    input [7:0] B,
    input [3:0] opcode,
    output reg [7:0] ALU_OUT,
    output reg Zero_Flag,
    output reg Negative_Flag,
    output reg Carry_Flag,
    output reg Overflow
    );

//internal_signal for combinational result
  reg [7:0] ALU_OUT_Comb;
 
// Sequential: Register output on clock edge
always @(posedge CLK)
 begin
   ALU_OUT <= ALU_OUT_Comb;
 end  

// Combinational: Calculate Result and Flags
always @ (*) begin
 // Default values
  Zero_Flag = 1'b0;
  Negative_Flag = 1'b0;
  Carry_Flag = 1'b0;
  Overflow = 1'b0;
  ALU_OUT_Comb = 8'b0;


  case(opcode)
        4'b0000 : ALU_OUT_Comb = 8'b0;

        4'b0001 : ALU_OUT_Comb = B;

        4'b0010 : begin 
            {Carry_Flag, ALU_OUT_Comb} = A + B;
                Overflow = (~A[7] & ~B[7] & ALU_OUT_Comb[7]) | 
                            (A[7] & B[7] & ~ALU_OUT_Comb[7]);
            end

        4'b0011 : begin
                {Carry_Flag, ALU_OUT_Comb} = A - B;
                Overflow = (~A[7] & B[7] & ALU_OUT_Comb[7]) | 
                            (A[7] & ~B[7] & ~ALU_OUT_Comb[7]);
        end

        4'b0100 : ALU_OUT_Comb = A & B;

        4'b0101 : ALU_OUT_Comb = A | B;

        4'b0110 : begin
            case(A[1:0])
                2'b00: begin  // RLC - Rotate Left through Carry
                    ALU_OUT_Comb = {B[6:0], Carry_Flag};
                    Carry_Flag = B[7];
                end
                2'b01: begin  // RRC - Rotate Right through Carry
                    ALU_OUT_Comb = {Carry_Flag, B[7:1]};
                    Carry_Flag = B[0];
                end
                2'b10: begin  // SETC - Set Carry
                    Carry_Flag = 1'b1;
                end
                2'b11: begin  // CLRC - Clear Carry
                    Carry_Flag = 1'b0;
                end
            endcase

        end

        4'b1000: begin
            case(A[1:0])
                    2'b00: begin  // NOT - 1's Complement
                        ALU_OUT_Comb = ~B;
                    end
                    2'b01: begin  // NEG - 2's Complement
                        ALU_OUT_Comb = (~B) + 1'b1;
                    end
                    2'b10: begin  // INC - Increment
                        {Carry_Flag, ALU_OUT_Comb} = B + 1'b1;
                        Overflow = (~B[7] & ALU_OUT_Comb[7]);
                    end
                    2'b11: begin  // DEC - Decrement
                        {Carry_Flag, ALU_OUT_Comb} = B - 1'b1;
                        Overflow = (B[7] & ~ALU_OUT_Comb[7]);
                    end
                endcase
            end
                    

            default: ALU_OUT_Comb = 8'b0;

  endcase

  // Update Zero and Negative flags based on result
  // (except for SETC/CLRC operations)
  if (opcode != 4'b0110 || A[1:0] < 2'b10) begin
            Zero_Flag = (ALU_OUT_Comb == 8'b0);
            Negative_Flag = ALU_OUT_Comb[7];
        end
    
 end

endmodule