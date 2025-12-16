module pc_in_mux (
    input  [1:0] pc_src,
    input  [7:0] stack_val, // X[++sp]
    input  [7:0] reg_rb , // R[rb]
    input  [7:0] reset_addr,   // M[0]
    input  [7:0] interrupt_addr,  // M[1]
    output reg [7:0] pc_in
);
always @(*) begin
    case (pc_src)
        2'b00: pc_in = reset_addr;
        2'b01: pc_in = interrupt_addr;
        2'b10: pc_in = reg_rb;
        2'b11: pc_in = stack_val;
        default: pc_in = 8'b0;
    endcase 
end

endmodule
