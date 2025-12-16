module WB_CU_controls(

    // instruction fields in WB stage
    input [3:0] opcode,
    input [1:0] ra_wb,

    // RF write address/data selects
    output reg write_en,
    output reg sw1,         // 0 -> write ra, 1 -> write rb
    output reg sw2,         // 0 -> use wb_data, 1 -> force data_in

    // stack pointer controls (R3)
    output reg sp_inc,
    output reg sp_dec
);

    always @(*) begin
        write_en = 1'b0;
        sw1      = 1'b0;
        sw2      = 1'b0;
        sp_inc   = 1'b0;
        sp_dec   = 1'b0;
        
        case (opcode)
            // MOV, ADD, SUB, AND, OR, NOT/NEG/INC/DEC  (dest = ra)
            4'd1,
            4'd2,
            4'd3,
            4'd4,
            4'd5,
            4'd8: begin
                write_en = 1'b1;
                sw1      = 1'b0;  // write ra
                sw2      = 1'b0;  // normal WB data
            end

            // RLC/RRC/SETC/CLRC (opcode 6)
            4'd6: begin
                if (ra_wb == 2'b00 || ra_wb == 2'b01) begin
                    write_en = 1'b1;
                    sw1      = 1'b1;  // write rb
                    sw2      = 1'b0;
                end
            end

            // PUSH / POP / OUT / IN  (opcode 7)
            4'd7: begin
                case (ra_wb)
                    2'b00: begin
                        // PUSH: X[SP--] <- R[rb]
                        // stack pointer decremented AFTER write
                        sp_dec = 1'b1;
                        write_en = 1'b0; // RF write handled elsewhere (memory)
                    end
                    2'b01: begin
                        // POP: R[rb] <- X[++SP]
                        sp_inc   = 1'b1;
                        write_en = 1'b1;
                        sw1      = 1'b1;  // dest = rb
                        sw2      = 1'b0;  // data from MEM via WB path
                    end
                    2'b10: begin
                        // OUT: OUT.PORT <- R[rb] (no RF write)
                        write_en = 1'b0;
                    end
                    2'b11: begin
                        // IN: R[rb] <- IN.PORT
                        write_en = 1'b1;
                        sw1      = 1'b1;  // dest = rb
                        sw2      = 1'b1;  // force IO data
                    end
                endcase
            end

            // LDM (opcode 12, ra=0) -> R[rb] <- imm
            4'd12: begin
                if (ra_wb == 2'b00) begin
                    write_en = 1'b1;
                    sw1      = 1'b1;  // dest = rb
                    sw2      = 1'b0;
                end
            end

            // LDD/LDI (opcode 13) -> R[rb] <- M[...]
            4'd13: begin
                write_en = 1'b1;
                sw1      = 1'b1;  // dest = rb
                sw2      = 1'b0;
            end
        endcase
    end

endmodule
