module CU_CCR (
    input wire [3:0] op_code,
    input wire [1:0] ra,
    input wire       sf1,     // registered interrupt flag
    output reg Z_Flag_en,
    output reg N_Flag_en,
    output reg C_Flag_en,
    output reg V_Flag_en
);

    always @(*) begin
        // Default values
        Z_Flag_en = 1'b0;
        N_Flag_en = 1'b0;
        C_Flag_en = 1'b0;
        V_Flag_en = 1'b0;
        if(sf1)begin
            Z_Flag_en = 1'b0;
            N_Flag_en = 1'b0;
            C_Flag_en = 1'b0;
            V_Flag_en = 1'b0;
        end
        else begin
            case (op_code)
                
                4'b0010 , 4'b0011: begin //ADD , SUB
                    Z_Flag_en = 1'b1;
                    N_Flag_en = 1'b1;
                    C_Flag_en = 1'b1;
                    V_Flag_en = 1'b1;
                end

                4'b0100 , 4'b0101: begin //AND , OR
                    Z_Flag_en = 1'b1;
                    N_Flag_en = 1'b1;
                end

                4'b0110: begin // RLC , RRC , SETC , CLRC
                    C_Flag_en = 1'b1;
                end

                4'b1000: begin
                    case (ra)
                        2'b00 , 2'b01: begin // NOT , NEG
                            Z_Flag_en = 1'b1;
                            N_Flag_en = 1'b1;
                        end
                        2'b10 , 2'b11: begin // INC , DEC
                            Z_Flag_en = 1'b1;
                            N_Flag_en = 1'b1;
                            C_Flag_en = 1'b1;
                            V_Flag_en = 1'b1;
                        end
                    endcase
                end

                default: begin
                    Z_Flag_en = 1'b0;
                    N_Flag_en = 1'b0;
                    C_Flag_en = 1'b0;
                    V_Flag_en = 1'b0;
                end
            endcase            
        end

    end
endmodule