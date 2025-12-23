module CU
(
  input wire       clk ,
  input wire       rst ,
  input wire [3:0] op_code ,
  input wire [1:0] ra , 
  input wire [1:0] rb ,
  output reg  SE2 ,       //"1-> R[rb] , 0-> 1"
  output reg [1:0] SE3 , //"0-> ALU_res , 1-> R[ra] , 2-> R[rb]"
  output reg [3:0] ALU_CONTROL
);

always @ (*)
   begin
   //Default Values
   ALU_CONTROL = 4'b0000 ;
   SE2 = 1'b0  ;
   SE3 = 2'b00 ; //alu res

      case (op_code)
   
      4'b0001 : begin //MOV
         ALU_CONTROL = 4'b0001;
            SE3 = 2'b10 ; //forward R[rb]
      end

      4'b0010 : begin //ADD
         ALU_CONTROL = 4'b0010;
            SE2 = 1'b1  ;
      end

      4'b0011 : begin //SUB
         ALU_CONTROL = 4'b0011;
            SE2 = 1'b1  ;
      end

      4'b0100 : begin // AND
         ALU_CONTROL = 4'b0100;
            SE2 = 1'b1  ;
         end
   
      4'b0101 : begin //OR
         ALU_CONTROL = 4'b0101;
            SE2 = 1'b1  ;
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
      
      4'b0111 : begin 
         SE2 = 1'b0 ; // add 1 
         case (ra) 
            2'b00: begin //push
               ALU_CONTROL = 4'b0000; //NOP 
               SE3 = 2'b01 ; //pass R[ra]
            end
            2'b01: begin //pop
               ALU_CONTROL = 4'b0010; //add
               SE3 = 2'b00 ; //pass alu res
            end
            2'b10: begin //out
               ALU_CONTROL = 4'b0000; //NOP 
               SE3 = 2'b10 ; //pass R[rb]
            end
            default: begin
               ALU_CONTROL = 4'b0000; //NOP 
               SE3 = 2'b00 ;
            end
         endcase
      end

      4'b1000 : begin 
          SE2 = 1'b1  ; //pass R[rb]  
         case(ra)
            2'b00: begin  // NOT - 1's Complement
            ALU_CONTROL = 4'b1010 ; // ALU_CONTROL = op_code + ra + 2'b10
            end
            2'b01: begin  // NEG - 2's Complement
            ALU_CONTROL = 4'b1011 ;
            end
            2'b10: begin  // INC - Increment
            ALU_CONTROL = 4'b1100 ;
            end
            2'b11: begin  // DEC - Decrement
            ALU_CONTROL = 4'b1101 ;
            end
         endcase
      end
     
     4'b1010 : begin //LOOP
      ALU_CONTROL = 4'b0011 ; //sub
      SE2 = 1'b0 ; // 1
     end

     4'b1011 : begin 
      SE2 = 1'b0  ; //add 1 
      case (ra) 
            2'b01: begin //call
               ALU_CONTROL = 4'b0000; //NOP 
               SE3 = 2'b01 ;         //pass SP
            end
            2'b10,2'b11: begin //RET,RTI
               ALU_CONTROL = 4'b0010; //add
               SE3 = 2'b00 ; //pass alu res
            end
            default: begin
               ALU_CONTROL = 4'b0000; //NOP 
               SE3 = 2'b00 ;
            end
         endcase
     end

     4'b1100,4'b1101,4'b1110: begin //LDM,LDD,STD,LDI,STI
        SE3 = 2'b1 ; //pas IMM/R[ra]
     end

      default : begin 
         ALU_CONTROL = 4'b0000 ;
         SE2 = 1'b0  ;
         SE3 = 2'b00 ;
      end
      endcase
end

endmodule