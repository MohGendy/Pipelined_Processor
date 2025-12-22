module instruction_reg  (
    input  clk,rst,
    input  [7:0] ir_new,
    output reg [7:0] ir
);
    always @(posedge clk or negedge rst) begin
        if (!rst)
            ir <= 0;
        else
            ir<= ir_new;
    end
    
endmodule

