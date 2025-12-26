module instruction_reg  (
    input  clk,rst, flush,
    input  sf1_in,
    input  [7:0] ir_new,
    input  ld ,
    output reg reg_sf1,
    output reg [7:0] ir
);
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            ir <= 0;
            reg_sf1<= 0;
        end
        else if (flush) begin
            ir <= 0;
            reg_sf1<= 0;
        end
        else if (ld) begin
            ir <= ir_new;
            reg_sf1<= sf1_in;
        end
    end
    
endmodule

