module IF_Stage (
input clk , byte_sel , if_en ,
input [7:0] mem_data , 
output reg [7:0] IR,
output reg [7:0] IMM
);
always @(posedge clk) begin
    if (if_en) begin
        if (byte_sel)
            IMM <= mem_data;
        else
            IR <= mem_data;
    end
end
endmodule