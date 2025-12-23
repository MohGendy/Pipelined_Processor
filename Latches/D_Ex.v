module D_Ex_Latch (
    // 1
    input [1:0]in_ra,
    input [1:0]in_rb,
    // 2
    input [7:0]in_R_ra,
    input [7:0]in_R_rb,
    // 3
    input in_RW,
    input [1:0]in_SP,
    input in_SW1,
    input in_SW2,
    input in_out_ld,
    // 4
    input in_MW,
    input in_SM1,
    input in_SM2,
    // 5
    input [3:0]in_ALU,
    input [4:0]in_Flags,
    input [2:0]in_BU,
    input in_SE1,
    input in_SE2,
    input [1:0]in_SE3,
    //6
    input in_Hlt,

    input clk,
    input reset,
    input ld,
    input flush,

    // 1
    output reg [1:0]ra,
    output reg [1:0]rb,
    // 2
    output reg [7:0]R_ra,
    output reg [7:0]R_rb,
    // 3
    output reg RW,
    output reg [1:0]SP,
    output reg SW1,
    output reg SW2,
    output reg out_ld,
    // 4
    output reg MW,
    output reg SM1,
    output reg SM2,
    // 5
    output reg [3:0]ALU,
    output reg [4:0]Flags,
    output reg [2:0]BU,
    output reg SE1,
    output reg SE2,
    output reg [1:0]SE3,
    // 6
    output reg Hlt

);


    always @(posedge clk or negedge reset) begin
        if(!reset || flush) begin
            // 1
            ra <= 2'b0;
            rb <= 2'b0;
            // 2
            R_ra <= 8'b0;
            R_rb <= 8'b0;
            // 3
            RW <= 1'b0;
            SP <= 2'b0;
            SW1 <= 1'b0;
            SW2 <= 1'b0;
            out_ld <= 1'b0;
            // 4
            MW <= 1'b0;
            SM1 <= 1'b0;
            SM2 <= 1'b0;
            // 5
            ALU <= 4'b0;
            Flags <= 5'b0;
            BU <= 3'b0;
            SE1 <= 1'b0;
            SE2 <= 1'b0;
            SE3 <= 2'b0;
            // 6
            Hlt <= 1'b0;
            
        end 
        else begin
            if (ld) begin                
                // 1
                ra <= in_ra;
                rb <= in_rb;
                // 2
                R_ra <= in_R_ra;
                R_rb <= in_R_rb;
                // 3
                RW <= in_RW;
                SP <= in_SP;
                SW1 <= in_SW1;
                SW2 <= in_SW2;
                out_ld <= in_out_ld;
                // 4
                MW <= in_MW;
                SM1 <= in_SM1;
                SM2 <= in_SM2;
                // 5
                ALU <= in_ALU;
                Flags <= in_Flags;
                BU <= in_BU;
                SE1 <= in_SE1;
                SE2 <= in_SE2;
                SE3 <= in_SE3;
                // 6
                Hlt <= in_Hlt;
            end            
        end
    end
endmodule