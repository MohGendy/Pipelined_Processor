module bypass_jmp(

    // 0 = JMP, 1 = CALL
    input wire brx, 

    // this is a signal generated from CU in order to say that this is a jump instruction
    input wire jmp_group,

    // rb of current JMP/CALL (jump target register)
    input wire [2:0] rb_ex,

    // From EX/MEM (previous instruction)
    input wire we_mem,
    input wire [2:0] dest_mem,

    // From MEM/WB (before previous instruction)
    input wire we_wb,
    input wire [2:0] dest_wb,

    // stall request in Fetch/Decode
    output reg flush
);

    wire jmp_or_call, hazard_mem, hazard_wb;

    assign jmp_or_call = jmp_group && (brx == 1'b0 || brx == 1'b1);
    assign hazard_mem = we_mem && (dest_mem == rb_ex);
    assign hazard_wb  = we_wb && (dest_wb  == rb_ex);

    always @(*) begin
	flush = jmp_or_call && (hazard_mem || hazard_wb);
    end

endmodule