module Ex_M_Latch (
    // 1
    input [1:0]in_ra,
    input [1:0]in_rb,
    // 3
    input in_RW,
    input [1:0]in_SP,
    input in_SW1,
    input in_SW2,
    input in_out_ld,
    // 5
    input [7:0]in_DataOut,

    input clk,

    // 1
    output reg [1:0]ra,
    output reg [1:0]rb,
    // 3
    output reg RW,
    output reg [1:0]SP,
    output reg SW1,
    output reg SW2,
    output reg out_ld,
    // 5
    output reg [7:0]DataOut

);


    always @(posedge clk ) begin
        // 1
        ra <= in_ra;
        rb <= in_rb;
        // 3
        RW <= in_RW;
        SP <= in_SP;
        SW1 <= in_SW1;
        SW2 <= in_SW2;
        out_ld <= in_out_ld;
        // 5
        DataOut <= in_DataOut;
    end
endmodule