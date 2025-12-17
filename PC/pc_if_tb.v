`timescale 1ns/1ps

module tb_pc_system;

    // Clock and Reset
    reg clk;
    reg reset;
    reg intr;

    // Decode signals (from execute stage)
    reg [3:0] opcode;
    reg [1:0] brx;

    // Flags
    reg Z_flag, N_flag, C_flag, V_flag;

    // Register and stack inputs
    reg [7:0] data_out;    // Stack value for RET/RTI
    reg [7:0] reg_rb_d;    // R[rb] from decode stage
    reg [7:0] reg_rb_ex;   // R[rb] from execute stage

    // Memory simulation
    reg [7:0] memory [0:255];
    wire [7:0] I_out;      // Memory data output
    
    // PC outputs
    wire [7:0] pc_out;
    wire [7:0] mem_addr;

    // Control signals
    wire pc_en;
    wire pc_load;
    wire byte_sel;
    wire if_en;
    wire instr_done;
    wire [1:0] pc_src;
    wire [1:0] addr_src;

    // Internal signals
    wire [7:0] pc_in;

    // ================= Module Instantiations =================
    
    PC_CU control_unit (
        .clk(clk),
        .reset(reset),
        .intr(intr),
        .opcode(opcode),
        .brx(brx),
        .Z_flag(Z_flag),
        .N_flag(N_flag),
        .C_flag(C_flag),
        .V_flag(V_flag),
        .pc_en(pc_en),
        .pc_load(pc_load),
        .byte_sel(byte_sel),
        .if_en(if_en),
        .instr_done(instr_done),
        .pc_src(pc_src),
        .addr_src(addr_src)
    );
    
    pc_in_mux pc_mux (
        .pc_src(pc_src),
        .data_out(data_out),
        .reg_rb_d(reg_rb_d),
        .I_out(I_out),
        .reg_rb_ex(reg_rb_ex),
        .pc_in(pc_in)
    );
    
    PC program_counter (
        .clk(clk),
        .pc_load(pc_load),
        .pc_en(pc_en),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );
    
    mem_addr_mux addr_mux (
        .addr_src(addr_src),
        .pc(pc_out),
        .mem_addr(mem_addr)
    );

    // ================= Memory Model =================
    assign I_out = memory[mem_addr];

    // ================= Clock Generation =================
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 20ns period (50MHz)
    end

    // ================= VCD Dump =================
    initial begin
        $dumpfile("pc_system_tb.vcd");
        $dumpvars(0, tb_pc_system);
    end

    // Test scenario counter
    integer test_num;
    integer pass_count;
    integer fail_count;

    // ================= Main Test =================
    initial begin
        // Initialize signals
        reset = 0;
        intr = 0;
        opcode = 4'b0000;
        brx = 2'b00;
        Z_flag = 0;
        N_flag = 0;
        C_flag = 0;
        V_flag = 0;
        data_out = 8'h00;
        reg_rb_d = 8'h00;
        reg_rb_ex = 8'h00;
        test_num = 0;
        pass_count = 0;
        fail_count = 0;

        // Initialize memory
        initialize_memory();

        // Display header
        $display("\n========================================");
        $display("  PC SYSTEM TESTBENCH");
        $display("========================================\n");

        // Test 1: Reset Sequence
        test_num = 1;
        $display("Test %0d: Reset Sequence", test_num);
        reset = 1;
        repeat(3) @(posedge clk);
        reset = 0;
        @(posedge clk);
        check_pc(8'h10, "After reset, PC should load M[0] = 0x10");

        // Test 2: Single-byte instruction (NOP)
        test_num = 2;
        $display("\nTest %0d: Single-byte instruction (NOP)", test_num);
        opcode = 4'h0;  // NOP
        wait_for_instr_done();
        check_pc(8'h11, "PC should increment by 1");

        // Test 3: Another NOP
        test_num = 3;
        $display("\nTest %0d: Another NOP", test_num);
        opcode = 4'h0;
        wait_for_instr_done();
        check_pc(8'h12, "PC should increment to 0x12");

        // Test 4: Two-byte instruction (LDM)
        test_num = 4;
        $display("\nTest %0d: Two-byte instruction (LDM)", test_num);
        opcode = 4'hC;  // LDM (opcode=12)
        wait_for_instr_done();
        check_pc(8'h14, "PC should increment by 2 (now at 0x14)");

        // Test 5: Another 2-byte instruction (LDD)
        test_num = 5;
        $display("\nTest %0d: Two-byte instruction (LDD)", test_num);
        opcode = 4'hC;  // LDD
        wait_for_instr_done();
        check_pc(8'h16, "PC should increment by 2 (now at 0x16)");

        // Test 6: Conditional branch NOT taken (JZ with Z=0)
        test_num = 6;
        $display("\nTest %0d: Conditional branch NOT taken (JZ, Z=0)", test_num);
        Z_flag = 0;
        opcode = 4'd9;  // Conditional branch
        brx = 2'd0;     // JZ
        wait_for_instr_done();
        check_pc(8'h17, "PC should increment normally by 1");

        // Test 7: Conditional branch TAKEN (JZ with Z=1)
        test_num = 7;
        $display("\nTest %0d: Conditional branch TAKEN (JZ, Z=1)", test_num);
        Z_flag = 1;
        reg_rb_ex = 8'h20;  // Jump target
        opcode = 4'd9;
        brx = 2'd0;
        wait_for_instr_done();
        check_pc(8'h20, "PC should jump to R[rb]=0x20");

        // Test 8: Instruction after jump
        test_num = 8;
        $display("\nTest %0d: Instruction after jump", test_num);
        Z_flag = 0;
        opcode = 4'd0;  // NOP
        wait_for_instr_done();
        check_pc(8'h21, "PC should increment from jump target");

        // Test 9: JMP instruction (unconditional)
        test_num = 9;
        $display("\nTest %0d: Unconditional jump (JMP)", test_num);
        reg_rb_d = 8'h30;
        opcode = 4'd11;
        brx = 2'd0;  // JMP
        wait_for_instr_done();
        check_pc(8'h30, "PC should jump to R[rb]=0x30");

        // Test 10: CALL instruction
        test_num = 10;
        $display("\nTest %0d: CALL instruction", test_num);
        reg_rb_d = 8'h40;
        opcode = 4'd11;
        brx = 2'd1;  // CALL
        wait_for_instr_done();
        check_pc(8'h40, "PC should jump to subroutine at 0x40");

        // Test 11: RET instruction
        test_num = 11;
        $display("\nTest %0d: RET instruction", test_num);
        data_out = 8'h50;  // Return address from stack
        opcode = 4'd11;
        brx = 2'd2;  // RET
        wait_for_instr_done();
        check_pc(8'h50, "PC should return from stack to 0x50");

        // Test 12: LOOP instruction (continue looping, Z=0)
        test_num = 12;
        $display("\nTest %0d: LOOP instruction (continue looping)", test_num);
        Z_flag = 0;  // Counter not zero
        reg_rb_ex = 8'h60;
        opcode = 4'd10;  // LOOP
        wait_for_instr_done();
        check_pc(8'h60, "PC should loop back to 0x60");

        // Test 13: LOOP instruction (exit loop, Z=1)
        test_num = 13;
        $display("\nTest %0d: LOOP instruction (exit loop)", test_num);
        Z_flag = 1;  // Counter is zero
        opcode = 4'd10;
        wait_for_instr_done();
        check_pc(8'h61, "PC should continue normally to 0x61");

        // Test 14: Interrupt handling
        test_num = 14;
        $display("\nTest %0d: Interrupt handling", test_num);
        Z_flag = 0;
        opcode = 4'd0;  // Normal instruction
        wait(control_unit.state == 2'd1);  // FETCH1
        @(posedge clk);
        intr = 1;
        wait(control_unit.state == 2'd3);  // DONE
        @(posedge clk);  
        intr = 0;
        @(posedge clk);  
        check_pc(8'h70, "PC should jump to interrupt vector M[1] = 0x70");
       
        // Test 15: Instruction at interrupt handler
        test_num = 15;
        $display("\nTest %0d: Instruction at interrupt handler", test_num);
        opcode = 4'd0;  // NOP
        wait_for_instr_done();
        check_pc(8'h71, "PC should increment to 0x71");

        // Test 16: RTI instruction
        test_num = 16;
        $display("\nTest %0d: RTI instruction", test_num);
        data_out = 8'h80;  // Return address
        opcode = 4'd11;
        brx = 2'd3;  // RTI
        wait_for_instr_done();
        check_pc(8'h80, "PC should return from interrupt to 0x80");

        // Test 17: Sequential instructions
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
        reg_rb_ex = 8'h90;
        opcode = 4'd9;
        brx = 2'd1;  // JN
        wait_for_instr_done();
        check_pc(8'h90, "PC should jump on negative flag");

        // Test 19: JC with C=1
        test_num = 19;
        $display("\nTest %0d: JC branch taken (C=1)", test_num);
        N_flag = 0;
        C_flag = 1;
        reg_rb_ex = 8'hA0;
        opcode = 4'd9;
        brx = 2'd2;  // JC
        wait_for_instr_done();
        check_pc(8'hA0, "PC should jump on carry flag");

        // Test 20: JV with V=1
        test_num = 20;
        $display("\nTest %0d: JV branch taken (V=1)", test_num);
        C_flag = 0;
        V_flag = 1;
        reg_rb_ex = 8'hB0;
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

        // Test 22: Memory addressing during reset
        test_num = 22;
        $display("\nTest %0d: Memory addressing verification", test_num);
        reset = 1;
        @(posedge clk);
        @(posedge clk);  // Wait for FSM to enter RESET state
        if (addr_src == 2'b01 && mem_addr == 8'h00) begin
            $display("  [PASS] Reset uses M[0] (addr_src=01, mem_addr=0x00)");
            pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] Reset addressing incorrect (addr_src=%b, mem_addr=0x%h)", addr_src, mem_addr);
            fail_count = fail_count + 1;
        end
        reset = 0;
        //repeat(3) @(posedge clk);

        // Test 23: Interrupt addressing
        test_num = 23;
        $display("\nTest %0d: Interrupt memory addressing", test_num);
        opcode = 4'd0;
        wait(control_unit.state == 2'd1);  // Wait for FETCH1
        @(posedge clk);
        intr = 1;
        @(posedge clk);  // Let FSM process interrupt
        wait(control_unit.state == 2'd3);  // Wait for DONE state
        #1;  // Small delay for combinational logic to settle
        if (addr_src == 2'b10 && mem_addr == 8'h01) begin
            $display("  [PASS] Interrupt uses M[1] (addr_src=10, mem_addr=0x01)");
            pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] Interrupt addressing incorrect (addr_src=%b, mem_addr=0x%h)", addr_src, mem_addr);
            fail_count = fail_count + 1;
        end
        intr = 0;
        //repeat(2) @(posedge clk);

        // Summary
        $display("\n========================================");
        $display("  TEST SUMMARY");
        $display("========================================");
        $display("  Total Tests: %0d", pass_count + fail_count);
        $display("  Passed: %0d", pass_count);
        $display("  Failed: %0d", fail_count);
        if (fail_count == 0)
            $display("  Status: ALL TESTS PASSED!");
        else
            $display("  Status: SOME TESTS FAILED!");
        $display("========================================\n");

        #100;
        $stop;
    end

    // ================= Helper Tasks =================

    // Initialize memory with test data
    task initialize_memory;
        integer i;
        begin
            // Clear memory
            for (i = 0; i < 256; i = i + 1)
                memory[i] = 8'h00;

            // Reset and interrupt vectors
            memory[8'h00] = 8'h10;  // M[0] = 0x10 (reset vector)
            memory[8'h01] = 8'h70;  // M[1] = 0x70 (interrupt vector)

            // Test program starting at 0x10
            memory[8'h10] = 8'h00;  // NOP
            memory[8'h11] = 8'h29;  // ADD R2, R1
            memory[8'h12] = 8'hC1;  // LDM R1, #0x55
            memory[8'h13] = 8'h55;  // Immediate value
            memory[8'h14] = 8'hC6;  // LDD R2, [0xAA]
            memory[8'h15] = 8'hAA;  // Effective address
            memory[8'h16] = 8'h90;  // JZ R0
            memory[8'h17] = 8'h91;  // JZ R1
            
            // Jump target locations
            memory[8'h20] = 8'hCC;
            memory[8'h21] = 8'hBB;
            memory[8'h30] = 8'hDD;
            memory[8'h40] = 8'hEE;
            memory[8'h50] = 8'h11;
            memory[8'h60] = 8'hFF;
            memory[8'h61] = 8'h22;
            memory[8'h70] = 8'h33;  // Interrupt handler
            memory[8'h71] = 8'h44;
            memory[8'h80] = 8'h55;  // Return from interrupt
            memory[8'h81] = 8'h66;
            memory[8'h82] = 8'h77;
            memory[8'h83] = 8'h88;
            memory[8'h90] = 8'h99;  // JN target
            memory[8'hA0] = 8'hAA;  // JC target
            memory[8'hB0] = 8'hBB;  // JV target
            memory[8'hB1] = 8'hCC;
        end
    endtask

    // Wait for instruction completion
    task wait_for_instr_done;
        begin
            @(posedge instr_done);
            @(negedge clk);
        end
    endtask

    // Check PC value
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

    // ================= Monitors =================

    // State transition monitor
    always @(posedge clk) begin
        if (control_unit.state != control_unit.next_state)
            $display("    [State] %0d -> %0d | PC=0x%02h | pc_was_loaded=%b", 
                     control_unit.state, control_unit.next_state, pc_out, control_unit.pc_was_loaded);
    end

    // Control signal monitor
    always @(posedge clk) begin
        if (pc_load)
            $display("    [PC Load] pc_in=0x%02h (src=%b) -> PC will be 0x%02h next cycle", 
                     pc_in, pc_src, pc_in);
    end

endmodule
