module mux_4to1 #(parameter size = 8) (
    input  [1:0] sel,
    input  [size-1:0] in0,
    input  [size-1:0] in1,
    input  [size-1:0] in2,
    input  [size-1:0] in3,
    output reg [size-1:0] out
);
always @(*) begin
    case (sel)
        2'b00: out = in0;
        2'b01: out = in1;
        2'b10: out = in2;
        2'b11: out = in3;
    endcase
end
endmodule
