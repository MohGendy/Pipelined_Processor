module ALU (
    input wire [7:0] A,
    input wire [7:0] B,
    input wire [3:0] ALU_CONTROL,
    input wire Carry_Flag_IN,
    output reg [7:0] ALU_OUT,
    output reg Zero_Flag,
    output reg Negative_Flag,
    output reg Carry_Flag_OUT,
    output reg Overflow
    );


// Combinational: Calculate Result and Flags
always @ (*) begin
 // Default values
  Zero_Flag = 1'b0;
  Negative_Flag = 1'b0;
  Carry_Flag_OUT = 1'b0;
  Overflow = 1'b0;
  ALU_OUT = 8'b0;


  case(ALU_CONTROL)

        4'b0001 : ALU_OUT = B; //MOV

        4'b0010 : begin  //ADD
            {Carry_Flag_OUT, ALU_OUT} = A + B;
                Overflow = (~A[7] & ~B[7] & ALU_OUT[7]) | 
                            (A[7] & B[7] & ~ALU_OUT[7]);
            end

        4'b0011 : begin //SUB
                {Carry_Flag_OUT, ALU_OUT} = A - B;
                Overflow = (~A[7] & B[7] & ALU_OUT[7]) | 
                            (A[7] & ~B[7] & ~ALU_OUT[7]);
        end

        4'b0100 : ALU_OUT = A & B; //AND

        4'b0101 : ALU_OUT = A | B; //OR

        4'b0110 : begin // RLC - Rotate Left through Carry
            ALU_OUT = {B[6:0], Carry_Flag_IN};
            Carry_Flag_OUT = B[7];
        end
                
        4'b0111 : begin  // RRC - Rotate Right through Carry
            ALU_OUT = {Carry_Flag_IN, B[7:1]};
            Carry_Flag_OUT = B[0];
        end

        4'b1000 : begin  // SETC - Set Carry
            Carry_Flag_OUT = 1'b1;
        end

        4'b1001 : begin  // CLRC - Clear Carry
            Carry_Flag_OUT = 1'b0;
        end
    
        4'b1010 : begin  // NOT - 1's Complement
            ALU_OUT = ~B;
        end
        4'b1011 : begin  // NEG - 2's Complement
            ALU_OUT = (~B) + 1'b1;
        end
        4'b1100 : begin  // INC - Increment
            {Carry_Flag_OUT, ALU_OUT} = B + 1'b1;
            Overflow = (~B[7] & ALU_OUT[7]);
        end
        4'b1101 : begin  // DEC - Decrement
            {Carry_Flag_OUT, ALU_OUT} = B - 1'b1;
            Overflow = (B[7] & ~ALU_OUT[7]);
        end      

        default: begin 
            Zero_Flag = 1'b0;
            Negative_Flag = 1'b0;
            Carry_Flag_OUT = 1'b0;
            Overflow = 1'b0;
            ALU_OUT = 8'b0;
        end
endcase

  // Update Zero and Negative flags based on result
  // (except for SETC/CLRC operations)
  if (ALU_CONTROL != 4'b1000 || ALU_CONTROL != 4'b1001 ) begin
            Zero_Flag = (ALU_OUT == 8'b0) ;
            Negative_Flag = (ALU_OUT[7] == 1'b1) ;
        end
    
 end

endmodule