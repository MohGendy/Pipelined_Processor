module instruction_reg  (
    input  clk,
    input  [7:0] ir_new,
    output reg [7:0] ir
);
    always @(posedge clk) begin
            ir <= ir_new;
    end
 
endmodule