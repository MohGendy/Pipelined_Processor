module Write_Back_Stage_CU(

    // instruction fields in WB stage
    input [3:0] opcode,
    input [1:0] ra_wb,
    input wire  sf1 ,     // registered interrupt flag

    // RF write address/data selects
    output reg write_en,
    output reg sw1,         // 0 -> write ra, 1 -> write rb
    output reg sw2,         // 0 -> use wb_data, 1 -> force data_in

    // stack pointer controls (R3)
    output reg sp_inc,
    output reg sp_dec,

    // out port ld signal
    output reg ld_out,
    output reg HLT_en
);

    always @(*) begin
        write_en = 1'b0;
        sw1      = 1'b0;
        sw2      = 1'b0;
        sp_inc   = 1'b0;
        sp_dec   = 1'b0;
        ld_out   = 1'b0;
        HLT_en   = 1'b0;
        if (sf1) begin
            write_en = 1'b0;
            sw1      = 1'b0;
            sw2      = 1'b0;
            sp_inc   = 1'b0;
            sp_dec   = 1'b1;
            ld_out   = 1'b0;
            HLT_en   = 1'b0;
        end
        else begin            
            case (opcode)
                // MOV, ADD, SUB, AND, OR, NOT/NEG/INC/DEC  (dest = ra)
                4'd1,
                4'd2,
                4'd3,
                4'd4,
                4'd5: begin
                    write_en = 1'b1;
                    sw1      = 1'b0;  // write ra
                    sw2      = 1'b0;  // normal WB data
                end
                4'd8: begin
                    write_en = 1'b1;
                    sw1      = 1'b1;  // write ra
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
                            ld_out   = 1'b1;
                        end
                        2'b11: begin
                            // IN: R[rb] <- IN.PORT
                            write_en = 1'b1;
                            sw1      = 1'b1;  // dest = rb
                            sw2      = 1'b1;  // force IO data
                        end
                    endcase
                end


                // loop (opcode 10)
                4'd10: begin
                    write_en = 1'b1;
                    sw1      = 1'b0;
                    sw2      = 1'b0;
                end

                // CALL / RET / RTI (opcode 11, ra=1,2,3)
                4'd11: begin
                    if(ra_wb == 2'b01) sp_dec = 1'b1;
                    else if(ra_wb == 2'b10 || ra_wb == 2'b11 ) sp_inc = 1'b1;
                end

                // LDM/LDD (opcode 12, ra=0,1) -> R[rb] <- data_out
                4'd12: begin
                    if (ra_wb == 2'b00 || ra_wb == 2'b01) begin
                        write_en = 1'b1;
                        sw1      = 1'b1;  // dest = rb
                        sw2      = 1'b0;
                    end
                end

                // LDI (opcode 13) -> R[rb] <- data_out
                4'd13: begin
                    write_en = 1'b1;
                    sw1      = 1'b1;  // dest = rb
                    sw2      = 1'b0;
                end
                4'd15: begin //HLT  //! MISSING , logic to stop the CPU
                    HLT_en = 1'b1 ;
                end
                default: begin
                    write_en = 1'b0;
                    sw1      = 1'b0;
                    sw2      = 1'b0;
                    sp_inc   = 1'b0;
                    sp_dec   = 1'b0;
                    ld_out   = 1'b0;
                    HLT_en   = 1'b0;
                end
            endcase
        end
    end

endmodule
