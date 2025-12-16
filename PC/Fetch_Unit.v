module Fetch_Unit (
    input         clk,
    input         reset,
    input         intr,

    input   [3:0]  opcode,
    input   [1:0]  brx,

    input  Z_flag,
    input  N_flag,
    input  C_flag,
    input  V_flag,

    input  [7:0] mem_data,
    input  [7:0] stack_val, // X[++sp]
    input  [7:0] reg_rb , // R[rb]
    input  [7:0] reset_addr,   // M[0]
    input  [7:0] interrupt_addr,  // M[1]

    output [7:0] IR,
    output [7:0] IMM,
    output        instr_done,
    output [7:0] pc_out
);
    wire        pc_en, pc_load, byte_sel, if_en;
    wire [1:0]  pc_src;
    wire [7:0]  pc_in;

    PC_CU pc_cu (
        .clk        (clk),
        .reset      (reset),
        .intr       (intr),
        .opcode     (opcode),
        .brx        (brx),
        .Z_flag     (Z_flag),
        .N_flag     (N_flag),
        .C_flag     (C_flag),
        .V_flag     (V_flag),
        .pc_en      (pc_en),
        .pc_load    (pc_load),
        .byte_sel   (byte_sel),
        .if_en      (if_en),
        .instr_done (instr_done),
        .pc_src     (pc_src)
    );

    pc_in_mux pc_mux (
        .pc_src           (pc_src),
        .stack_val        (stack_val),
        .reg_rb           (reg_rb),
        .reset_addr       (reset_addr),
        .interrupt_addr   (interrupt_addr),
        .pc_in            (pc_in)
    );

    PC program_counter (
        .clk     (clk),
        .pc_load (pc_load),
        .pc_en   (pc_en),
        .pc_in   (pc_in),
        .pc_out  (pc_out)
    );

    IF_Stage if_stage (
        .clk     (clk),
        .byte_sel  (byte_sel),
        .if_en     (if_en),
        .mem_data  (mem_data),
        .IR        (IR),
        .IMM       (IMM)
    );
endmodule