module PC (
    input  clk,
    input  pc_load,
    input  [7:0] pc_new,
    output reg [7:0] pc
);
    always @(posedge clk) begin
        if (pc_load)
            pc <= pc_new;
    end
endmodule
