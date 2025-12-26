// Control Unit Snippet for Register File MUX Selection
// This module generates the control signals for the three MUXes
// preceding the Register File based on the ISA and the Datapath architecture.

module RegFile_ControlUnit (
    // Inputs from Instruction Register (IR)
    input wire [3:0] Opcode,     // IR[7:4]
    input wire [1:0] ra_brx,     // IR[3:2] (used for ra or brx field)
    input wire       sf1,        // registered interrupt flag



    // Outputs (Control Signals for MUXes)
    // MUX Logic: 0 = Default/Top input; 1 = Alternate/Bottom input
    output reg SD1,              // MUX 1: Write Address Selector (0=IR[ra], 1=3/SP)
    output reg SD2,              // MUX 2: Read A Selector (0= Immediate Value (Imm), 1=R[ra])
    output reg [1:0] SD3         // MUX 3: Read B Selector (0=R[rb], 1=PC+1, 2=IR)
);

    // Opcodes Constants
    localparam OP_NOP     = 4'd0;  // NOP
    localparam OP_PUSH_POP= 4'd7;  // PUSH / POP instructions
    localparam OP_CALL    = 4'd11; // CALL / JMP / RET / RTI instructions
    localparam OP_LD_ST_I = 4'd12; // LDM, LDD, STD instructions

    // Instruction Field Constants
    localparam RA_PUSH  = 2'd0;  // ra=0 for PUSH (Opcode 7)
    localparam RA_POP   = 2'd1;  // ra=1 for POP (Opcode 7)    
    localparam BRX_CALL = 2'd1;  // brx=1 for CALL (Opcode 11)
    localparam BRX_RET  = 2'd2;  // brx=2 for RET (Opcode 11)
    localparam BRX_RTI  = 2'd3;  // brx=3 for RTI (Opcode 11)

    // Combinational Logic to Generate MUX Control Signals
    
    always @(*) begin
        
        // 1. Default settings for all MUXes (R-Format and general instructions)
        // SD1 default is 0 for R[ra]. SD2 default is 1 for R[ra]. SD3 default is 0 for R[rb].

        //! default values
        //? SD1 = 1'b0; 
        //? SD2 = 1'b1; 
        //? SD3 = 1'b0; 
        if(sf1)begin
            SD1 = 1'b1; 
            SD2 = 1'b1; 
            SD3 = 2'b10; 
        end
        else begin
            case (Opcode)
                // NOP (OPcode 0)
                OP_NOP: begin
                    SD1 = 1'b1;
                    SD2 = 1'b1; 
                    SD3 = 1'b0; 
                end
                // PUSH/POP Instructions (Opcode 7)
                OP_PUSH_POP: begin
                    SD2 = 1'b1; 
                    SD3 = 2'b0; 
                    if (ra_brx == RA_PUSH) begin
                        // PUSH R[rb]: Modifies SP (R3). User requested SD1=1 for SP operations.
                        SD1 = 1'b1; // Select R3/SP address
                    end else if (ra_brx == RA_POP) begin
                        // POP R[rb]: Modifies SP (R3). User requested SD1=1 for SP operations.
                        SD1 = 1'b1; // Select R3/SP address
                    end else
                        SD1 = 1'b0; //return to default
                end

                // LD/ST/I Instructions (Opcode 12)
                OP_LD_ST_I: begin
                    // LDM Instruction (Opcode 12, ra=0). Function: R[rb] <- Imm. 
                    SD1 = 1'b0; 
                    SD2 = 1'b0; // Select Imm (0 according to your MUX definition)
                    SD3 = 2'b0; 
                end
                // CALL/JMP/RET/RTI Instructions (Opcode 11)
                OP_CALL: begin
                    SD2 = 1'b1; 
                    case (ra_brx)
                        BRX_CALL: begin
                            // CALL: X[SP--] <- PC+1. Modifies SP (R3). Requires MUX 3 to select PC+1.
                            SD1 = 1'b1; // Select R3/SP address (User request)
                            SD3 = 2'b1; // Select PC+1
                        end
                        BRX_RET: begin
                            // RET: PC <- X[++SP]. Modifies SP (R3).
                            SD1 = 1'b1; // Select R3/SP address (User request)
                            SD3 = 2'b0; // Select R[rb]
                        end
                        BRX_RTI: begin
                            // RTI: PC <- X[++SP]. Modifies SP (R3).
                            SD1 = 1'b1; // Select R3/SP address (User request)
                            SD3 = 2'b0; // Select R[rb]
                        end
                        default: begin
                            SD1 = 1'b0; 
                            SD3 = 2'b0;
                        end
                    endcase
                end
                default: begin
                    SD1 = 1'b0; 
                    SD2 = 1'b1; 
                    SD3 = 1'b0; 
                end
            endcase            
        end
        
    end

endmodule