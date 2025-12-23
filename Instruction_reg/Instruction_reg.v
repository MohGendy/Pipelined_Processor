module instruction_reg  (
    input  clk,rst, flush,
    input  [7:0] ir_new,
    output reg [7:0] ir
);
    always @(posedge clk or negedge rst) begin
        if (!rst || flush)
            ir <= 0;
        else
            ir<= ir_new;
    end
    
endmodule

