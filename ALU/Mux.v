module Mux_2x1 (
    input wire SE1,SE2,
    input wire [7:0] A , B ,
    output [7:0] OUT_1 , OUT_2
); 
    assign OUT_1 = SE1 ? A : 8'b0 ;
    assign OUT_2 = SE2 ? B : 8'b1 ;
endmodule

module Mux_4x1 (
    input wire [1:0] SE3 ,
    input wire [7:0] ALU_OUT,
    input wire [7:0] A , B ,
    output reg [7:0] OUT_3 
     );
     
     always @ (*) begin 

        case (SE3)
         
         2'b00 : OUT_3 = A ;
         2'b01 : OUT_3 = ALU_OUT ;
         2'b10 : OUT_3 = B ;
         2'b11 : OUT_3 = 8'b0 ;
     
        endcase
     end
    endmodule
