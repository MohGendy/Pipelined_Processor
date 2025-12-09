module pc_new(
    input  pc_src,
    input  [1:0] pc_in_sel,
    input  [7:0] pc_plus_1,
    input  [7:0] stack_addr, // X[++sp]
    input  [7:0] branch_addr, // R[rb]
    input  [7:0] reset_addr,   // M[0]
    input  [7:0] interrupt_addr,  // M[1]
    output [7:0] pc_new
);
    wire [7:0] pc_in;
mux_4to1 mux1 (
    .sel(pc_in_sel),
    .in0(interrupt_addr),
    .in1(stack_addr),
    .in2(branch_addr),
    .in3(reset_addr),
    .out(pc_in)
);

mux_2to1 mux2 (
    .sel(pc_src),
    .in0(pc_plus_1),
    .in1(pc_in),
    .out(pc_new)
);

endmodule
