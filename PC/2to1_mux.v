module mux_2to1 #(parameter size = 8) (
    input  sel,
    input  [size-1:0] in0,
    input  [size-1:0] in1,
    output reg [size-1:0] out
);
always @(*) begin
    if (sel)
        out = in1;
    else
        out = in0;
end
endmodule 
