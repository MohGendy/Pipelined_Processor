module PC (
    input  clk,
    input  pc_load, pc_en,
    input  [7:0] pc_in,
    output reg [7:0] pc_out
);

 always @(posedge clk) begin
        if (pc_en) begin
            if (pc_load)
                pc_out <= pc_in;
            else
                pc_out <= pc_out + 1;
        end
    end
endmodule