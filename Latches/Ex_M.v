module Ex_M_Latch (
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
    input [7:0]in_res,

    input clk,

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
    output reg [7:0]res

);


    always @(posedge clk ) begin
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
        res <= in_res;
    end
endmodule