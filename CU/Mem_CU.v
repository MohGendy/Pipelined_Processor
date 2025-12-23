module Mem_CU (
    input [7:0] IR ,               //the 8bit instruction
    output reg Wm ,               //write memory control
    output reg SM2               //memory mux2 selection (0->ALU res,1-> D_data memory port)
);

wire [3:0] op_code ;
wire [1:0] ra , rb ;

assign op_code = IR[7:4] ;
assign ra = IR[3:2] ; //or brx
assign rb = IR[1:0] ;

//Wm logic
    always @(*) begin
        case (op_code) 
            4'd7: begin //push
                if (ra == 2'd0) Wm = 1'b1 ;
                else Wm = 1'b0 ;
            end 
            4'd11: begin 
                if (ra == 2'd1) Wm = 1'b1 ; //call
                else Wm = 1'b0 ; 
            end
            4'd12: begin
                if (ra == 2'd2) Wm = 1'b1 ; //STD
                else Wm = 1'b0 ; 
            end
            4'd14: begin //STI
                Wm = 1'b1 ;
            end
            default: Wm = 1'b0 ;
        endcase
    end


//SM2 logic 
    always @(*) begin
        case (op_code) 
            4'd7: begin //pop
                if (ra == 2'd1) SM2 = 1'b1 ; //D_data
                else SM2 = 1'b0 ; 
            end 
            4'd11: begin 
                if (ra == 2'd2) SM2 = 1'b1 ;       //RET
                else if (ra == 2'd3) SM2 = 1'b1 ; //RTI
                else SM2 = 1'b0 ;
            end
            4'd12: begin //LDD
                if (ra == 2'd1) SM2 = 1'b1 ;
                else SM2 = 1'b0 ;
            end
            4'd13: begin //LDI
                SM2 = 1'b1 ;
            end
            default: SM2 = 1'b0 ; //res
        endcase
    end


endmodule