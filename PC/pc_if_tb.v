`timescale 1ns/1ps

module Fetch_Unit_TB;

    // Clock and Reset
    reg clk;
    reg reset;
    reg intr;

    // Decode signals (from execute stage)
    reg [3:0] opcode;
    reg [1:0] brx;

    // Flags
    reg Z_flag, N_flag, C_flag, V_flag;

    // Memory and register inputs
    reg [7:0] mem_data;
    reg [7:0] stack_val;
    reg [7:0] reg_rb;
    wire [7:0] reset_addr;      // M[0] - value from memory
    wire [7:0] interrupt_addr;  // M[1] - value from memory

    // Outputs
    wire [7:0] IR;
    wire [7:0] IMM;
    wire instr_done;
    wire [7:0] pc_out;

    // Instantiate the Fetch Unit
    Fetch_Unit uut (
        .clk(clk),
        .reset(reset),
        .intr(intr),
        .opcode(opcode),
        .brx(brx),
        .Z_flag(Z_flag),
        .N_flag(N_flag),
        .C_flag(C_flag),
        .V_flag(V_flag),
        .mem_data(mem_data),
        .stack_val(stack_val),
        .reg_rb(reg_rb),
        .reset_addr(reset_addr),
        .interrupt_addr(interrupt_addr),
        .IR(IR),
        .IMM(IMM),
        .instr_done(instr_done),
        .pc_out(pc_out)
    );

    // Clock generation (10ns period = 100MHz)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Memory model - simulates instruction memory
    reg [7:0] instruction_mem [0:255];
    
    // Memory response based on PC
    always @(*) begin
        mem_data = instruction_mem[pc_out];
    end

    // Reset and Interrupt vectors - read from memory
    assign reset_addr = instruction_mem[8'h00];      // PC gets M[0]
    assign interrupt_addr = instruction_mem[8'h01];  // PC gets M[1]

    // Test scenario counter
    integer test_num;
    integer pass_count;
    integer fail_count;

    initial begin
        // Initialize waveform dump
        $dumpfile("fetch_unit_tb.vcd");
        $dumpvars(0, Fetch_Unit_TB);

        // Initialize signals
        reset = 0;
        intr = 0;
        opcode = 4'b0000;
        brx = 2'b00;
        Z_flag = 0;
        N_flag = 0;
        C_flag = 0;
        V_flag = 0;
        stack_val = 8'h00;
        reg_rb = 8'h00;
        test_num = 0;
        pass_count = 0;
        fail_count = 0;

        // Initialize instruction memory with test program
        initialize_memory();

        // Display header
        $display("\n========================================");
        $display("  FETCH UNIT TESTBENCH");
        $display("========================================\n");

        // Test 1: Reset Sequence
        test_num = 1;
        $display("Test %0d: Reset Sequence", test_num);
        reset = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        reset = 0;
        @(posedge clk);
        check_pc(8'h10, "After reset, PC should load M[0] = 0x10");
        @(posedge clk);
        check_ir(8'h00, "Reset");

        // Test 2: Fetch 1-byte instruction (NOP at 0x00)
        // Fetch goes through FETCH1 -> DONE
        test_num = 2;
        $display("\nTest %0d: Fetch 1-byte instruction (NOP)", test_num);
        opcode = 4'h0;  // Decode stage says NOP (1-byte)
        wait_for_instr_done();
        check_ir(8'h00, "NOP instruction");
        check_pc(8'h11, "PC should increment by 1");

        // Test 3: Fetch 1-byte instruction (ADD R2, R1 at 0x11)
        test_num = 3;
        $display("\nTest %0d: Fetch 1-byte instruction (ADD)", test_num);
        opcode = 4'h2;  // Decode says ADD (1-byte)
        wait_for_instr_done();
        check_ir(8'h29, "ADD R2, R1 instruction");
        check_pc(8'h12, "PC should increment by 1");

        // Test 4: Fetch 2-byte instruction (LDM R1, #0x55 at 0x12-0x13)
        // Fetch goes through FETCH1 -> FETCH2 -> DONE
        test_num = 4;
        $display("\nTest %0d: Fetch 2-byte instruction (LDM)", test_num);
        opcode = 4'hC;  // Decode says LDM (2-byte, opcode=12)
        wait_for_instr_done();
        check_ir(8'hC1, "LDM R1 instruction opcode");
        check_imm(8'h55, "Immediate value 0x55");
        check_pc(8'h14, "PC should increment by 2 (now at 0x14)");

        // Test 5: Another 2-byte instruction (LDD R2, [0xAA] at 0x14-0x15)
        test_num = 5;
        $display("\nTest %0d: Fetch 2-byte instruction (LDD)", test_num);
        opcode = 4'hC;  // LDD also uses opcode 12, ra=1 distinguishes it
        wait_for_instr_done();
        check_ir(8'hC6, "LDD R2 instruction opcode");
        check_imm(8'hAA, "Effective address 0xAA");
        check_pc(8'h16, "PC should increment by 2 (now at 0x16)");

        // Test 6: Conditional branch not taken (JZ with Z=0)
        test_num = 6;
        $display("\nTest %0d: Conditional branch NOT taken (JZ, Z=0)", test_num);
        Z_flag = 0;
        opcode = 4'd9;  // JZ
        brx = 2'd0;
        wait_for_instr_done();
        check_ir(8'h90, "JZ R0 instruction");
        check_pc(8'h17, "PC should increment normally by 1");

        // Test 7: Conditional branch taken (JZ with Z=1)
        test_num = 7;
        $display("\nTest %0d: Conditional branch TAKEN (JZ, Z=1)", test_num);
        Z_flag = 1;
        reg_rb = 8'h20;  // Jump target
        opcode = 4'd9;
        brx = 2'd0;
        wait_for_instr_done();
        check_pc(8'h20, "PC should jump to R[rb]=0x20");

        // Test 8: Fetch instruction after jump
        test_num = 8;
        $display("\nTest %0d: Fetch after jump", test_num);
        opcode = 4'd0;  // Back to normal 1-byte instruction
        wait_for_instr_done();
        check_ir(8'hCC, "Instruction at jump target 0x20");
        check_pc(8'h21, "PC should increment from jump target");

        // Test 9: JMP instruction (unconditional, brx=0)
        test_num = 9;
        $display("\nTest %0d: Unconditional jump (JMP)", test_num);
        reg_rb = 8'h30;
        opcode = 4'd11;  // opcode 11
        brx = 2'd0;      // JMP
        wait_for_instr_done();
        check_pc(8'h30, "PC should jump to R[rb]=0x30");

        // Test 10: CALL instruction (brx=1)
        test_num = 10;
        $display("\nTest %0d: CALL instruction", test_num);
        reg_rb = 8'h40;
        opcode = 4'd11;
        brx = 2'd1;  // CALL
        wait_for_instr_done();
        check_pc(8'h40, "PC should jump to subroutine at 0x40");

        // Test 11: RET instruction (brx=2)
        test_num = 11;
        $display("\nTest %0d: RET instruction", test_num);
        stack_val = 8'h50;  // Return address from stack
        opcode = 4'd11;
        brx = 2'd2;  // RET
        wait_for_instr_done();
        check_pc(8'h50, "PC should return from stack to 0x50");

        // Test 12: LOOP instruction (counter != 0, Z=0)
        test_num = 12;
        $display("\nTest %0d: LOOP instruction (continue looping)", test_num);
        Z_flag = 0;  // Counter not zero after decrement
        reg_rb = 8'h60;
        opcode = 4'd10;  // LOOP
        wait_for_instr_done();
        check_pc(8'h60, "PC should loop back to 0x60");

        // Test 13: LOOP instruction (counter = 0, Z=1, exit loop)
        test_num = 13;
        $display("\nTest %0d: LOOP instruction (exit loop)", test_num);
        Z_flag = 1;  // Counter is zero after decrement
        opcode = 4'd10;
        wait_for_instr_done();
        check_pc(8'h61, "PC should continue normally to 0x61");

        // Test 14: Interrupt handling during FETCH1
        test_num = 14;
        $display("\nTest %0d: Interrupt handling", test_num);
        opcode = 4'd0;  // Normal instruction
        
        // Assert interrupt RIGHT when entering FETCH1 state
        wait(uut.pc_cu.state == 3'd1);  // Wait for FETCH1 state
        @(posedge clk);
        intr = 1;  // Trigger interrupt 
        @(posedge clk);
        @(posedge clk);
        intr = 0;
        
        // Wait for a few cycles for interrupt to be processed
        repeat(3) @(posedge clk);
        check_pc(8'h70, "PC should jump to interrupt vector M[1] = 0x70");

        // Test 15: Fetch one instruction at interrupt handler
        test_num = 15;
        $display("\nTest %0d: Fetch instruction at interrupt handler then RTI", test_num);
        opcode = 4'd0;  // The instruction at 0x70 is NOP (0x33 in memory, but treat as NOP for simplicity)
        wait_for_instr_done();
        check_pc(8'h71, "PC should increment to 0x71");
        
        // Test 16: execute RTI to return from interrupt
        test_num = 16;
        $display("\nTest %0d: RTI instruction", test_num);
        stack_val = 8'h80;  // Return from interrupt address
        opcode = 4'd11;
        brx = 2'd3;  // RTI
        wait_for_instr_done();
        check_pc(8'h80, "PC should return from interrupt to 0x80");

        // Test 17: Multiple consecutive 1-byte instructions
        test_num = 17;
        $display("\nTest %0d: Sequential 1-byte instructions", test_num);
        opcode = 4'd0;
        wait_for_instr_done();
        check_pc(8'h81, "First increment to 0x81");
        wait_for_instr_done();
        check_pc(8'h82, "Second increment to 0x82");
        wait_for_instr_done();
        check_pc(8'h83, "Third increment to 0x83");

        // Test 18: JN with N=1
        test_num = 18;
        $display("\nTest %0d: JN branch taken (N=1)", test_num);
        N_flag = 1;
        Z_flag = 0;
        reg_rb = 8'h90;
        opcode = 4'd9;
        brx = 2'd1;  // JN
        wait_for_instr_done();
        check_pc(8'h90, "PC should jump on negative flag");

        // Test 19: JC with C=1
        test_num = 19;
        $display("\nTest %0d: JC branch taken (C=1)", test_num);
        C_flag = 1;
        N_flag = 0;
        reg_rb = 8'hA0;
        opcode = 4'd9;
        brx = 2'd2;  // JC
        wait_for_instr_done();
        check_pc(8'hA0, "PC should jump on carry flag");

        // Test 20: JV with V=1
        test_num = 20;
        $display("\nTest %0d: JV branch taken (V=1)", test_num);
        V_flag = 1;
        C_flag = 0;
        reg_rb = 8'hB0;
        opcode = 4'd9;
        brx = 2'd3;  // JV
        wait_for_instr_done();
        check_pc(8'hB0, "PC should jump on overflow flag");

        // Test 21: JN with N=0 (not taken)
        test_num = 21;
        $display("\nTest %0d: JN branch NOT taken (N=0)", test_num);
        N_flag = 0;
        V_flag = 0;
        opcode = 4'd9;
        brx = 2'd1;  // JN
        wait_for_instr_done();
        check_pc(8'hB1, "PC should increment normally");

        // Summary
        $display("\n========================================");
        $display("  TEST SUMMARY");
        $display("========================================");
        $display("  Total Tests: %0d", pass_count + fail_count);
        $display("  Passed: %0d", pass_count);
        $display("  Failed: %0d", fail_count);
        $display("========================================\n");

        #100;
        $stop;
    end

    // Task to initialize memory with test instructions
    task initialize_memory;
        integer i;
        begin
            // Clear memory
            for (i = 0; i < 256; i = i + 1)
                instruction_mem[i] = 8'h00;

            // ===== RESET AND INTERRUPT VECTORS =====
            instruction_mem[8'h00] = 8'h10;  // M[0] = 0x10 (reset vector points to 0x10)
            instruction_mem[8'h01] = 8'h70;  // M[1] = 0x70 (interrupt vector points to 0x70)

            // ===== TEST PROGRAM STARTING AT 0x10 =====
            instruction_mem[8'h10] = 8'h00;  // NOP
            instruction_mem[8'h11] = 8'h29;  // ADD R2, R1
            instruction_mem[8'h12] = 8'hC1;  // LDM R1, #0x55 (opcode=C, ra=0, rb=1)
            instruction_mem[8'h13] = 8'h55;  // Immediate value
            instruction_mem[8'h14] = 8'hC6;  // LDD R2, [0xAA] (opcode=C, ra=1, rb=2)
            instruction_mem[8'h15] = 8'hAA;  // Effective address
            instruction_mem[8'h16] = 8'h90;  // JZ R0
            instruction_mem[8'h17] = 8'h91;  // JZ R1
            
            // ===== JUMP TARGET LOCATIONS =====
            instruction_mem[8'h20] = 8'hCC;  
            instruction_mem[8'h21] = 8'hBB;  
            instruction_mem[8'h30] = 8'hDD;  
            instruction_mem[8'h40] = 8'hEE;  
            instruction_mem[8'h50] = 8'h11;  
            instruction_mem[8'h60] = 8'hFF;  
            instruction_mem[8'h61] = 8'h22;
            instruction_mem[8'h70] = 8'h33;  // Interrupt handler at 0x70
            instruction_mem[8'h80] = 8'h44;  // Return from interrupt location
            instruction_mem[8'h81] = 8'h55;
            instruction_mem[8'h82] = 8'h66;
            instruction_mem[8'h83] = 8'h77;
            instruction_mem[8'h90] = 8'h88;  // JN target
            instruction_mem[8'hA0] = 8'h99;  // JC target
            instruction_mem[8'hB0] = 8'hAA;  // JV target
            instruction_mem[8'hB1] = 8'hBB;
        end
    endtask

    // Task to wait for instruction completion
    task wait_for_instr_done;
        begin
            @(posedge instr_done);
            @(negedge clk);  // Wait for signal to settle
        end
    endtask

    // Task to check PC value
    task check_pc;
        input [7:0] expected;
        input [80*8:1] msg;
        begin
            if (pc_out !== expected) begin
                $display("  [FAIL] PC Check: %s", msg);
                $display("         Expected: 0x%02h, Got: 0x%02h", expected, pc_out);
                fail_count = fail_count + 1;
            end else begin
                $display("  [PASS] PC = 0x%02h - %s", pc_out, msg);
                pass_count = pass_count + 1;
            end
        end
    endtask

    // Task to check IR value
    task check_ir;
        input [7:0] expected;
        input [80*8:1] msg;
        begin
            if (IR !== expected) begin
                $display("  [FAIL] IR Check: %s", msg);
                $display("         Expected: 0x%02h, Got: 0x%02h", expected, IR);
                fail_count = fail_count + 1;
            end else begin
                $display("  [PASS] IR = 0x%02h - %s", IR, msg);
                pass_count = pass_count + 1;
            end
        end
    endtask

    // Task to check IMM value (only for 2-byte instructions)
    task check_imm;
        input [7:0] expected;
        input [80*8:1] msg;
        begin
            if (IMM !== expected) begin
                $display("  [FAIL] IMM Check: %s", msg);
                $display("         Expected: 0x%02h, Got: 0x%02h", expected, IMM);
                fail_count = fail_count + 1;
            end else begin
                $display("  [PASS] IMM = 0x%02h - %s", IMM, msg);
                pass_count = pass_count + 1;
            end
        end
    endtask

    // Monitor for debugging - shows state transitions
    always @(posedge clk) begin
        if (uut.pc_cu.state != uut.pc_cu.next_state)
            $display("    [State] %0d -> %0d | PC=0x%02h | IR=0x%02h", 
                     uut.pc_cu.state, uut.pc_cu.next_state, pc_out, IR);
    end

endmodule
