module CU
(
  input wire       clk ,
  input wire       rst ,
  input wire [3:0] op_code ,
  input wire [1:0] ra , 
  input wire [1:0] rb ,
  output reg SE1 , SE2 ,
  output reg [1:0] SE3 , SE4 ,
  output reg [3:0] ALU_CONTROL
);

always @ (*)
   begin
   //Default Values
   ALU_CONTROL = 4'b0000 ;
   SE1 = 1'b0  ;
   SE2 = 1'b0  ;
   SE3 = 2'b00 ;
   SE4 = 2'b00 ;

      case (op_code)
   
      4'b0001 : begin //MOV
         ALU_CONTROL = 4'b0001;
            SE3 = 2'b10 ; //forward R[rb]
      end

      4'b0010 : begin //ADD
         ALU_CONTROL = 4'b0010;
            SE1 = 1'b1  ;
            SE2 = 1'b1  ;
      end

      4'b0011 : begin //SUB
         ALU_CONTROL = 4'b0011;
            SE1 = 1'b1  ;
            SE2 = 1'b1  ;
      end

      4'b0100 : begin // AND
         ALU_CONTROL = 4'b0100;
            SE1 = 1'b1  ;
            SE2 = 1'b1  ;
         end
   
      4'b0101 : begin //OR
         ALU_CONTROL = 4'b0101;
            SE1 = 1'b0  ;
            SE2 = 1'b0  ;
         end 

      4'b0110 : begin 
         case(ra)
            2'b00: begin  // RLC - Rotate Left through Carry
            ALU_CONTROL = 4'b0110 ; //  ALU_CONTROL = op_code + ra
               SE2 = 1'b1  ;
            end
            2'b01: begin  // RRC - Rotate Right through Carry
               ALU_CONTROL = 4'b0111 ; 
               SE2 = 1'b1  ;
            end
            2'b10: begin  // SETC - Set Carry
            ALU_CONTROL = 4'b1000 ;  
            end
            2'b11: begin  // CLRC - Clear Carry
            ALU_CONTROL = 4'b1001 ;
            end
            default : begin 
               SE2 = 1'b0  ;
            end
         endcase

      end 

      4'b1000 : begin 
         case(ra)
            2'b00: begin  // NOT - 1's Complement
            ALU_CONTROL = 4'b1010 ; // ALU_CONTROL = op_code + ra + 2'b10
               SE2 = 1'b1  ;   
            end
            2'b01: begin  // NEG - 2's Complement
            ALU_CONTROL = 4'b1011 ;
               SE2 = 1'b1  ;
            end
            2'b10: begin  // INC - Increment
            ALU_CONTROL = 4'b1100 ;
               SE2 = 1'b1  ;
            end
            2'b11: begin  // DEC - Decrement
            ALU_CONTROL = 4'b1011 ;
               SE2 = 1'b1  ;
            end
         endcase
      end
     
      default : begin 
         ALU_CONTROL = 4'b0000 ;
         SE1 = 1'b0  ;
         SE2 = 1'b0  ;
         SE3 = 2'b00 ;
         SE4 = 2'b00 ;
      end
      endcase
end

endmodule