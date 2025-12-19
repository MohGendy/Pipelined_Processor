module mem_addr_mux (
    input  [1:0] addr_src,
    input  [7:0] pc,
    output reg [7:0] mem_addr
);
always @(*) begin
    case (addr_src)
        2'b00: mem_addr = pc;    // normal fetch
        2'b01: mem_addr = 8'h00; // M[0] reset vector
        2'b10: mem_addr = 8'h01; // M[1] interrupt vector
        default: mem_addr = pc;
    endcase
end
endmodule

