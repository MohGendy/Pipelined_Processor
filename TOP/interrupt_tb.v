`timescale 1ns / 1ps

module interrupt_tb;

    // Testbench signals
    reg clk;
    reg rst;
    reg [7:0] In_port;
    reg interrupt;
    wire [7:0] Out_port;
    wire HLT_Flag;

    // Test statistics
    integer passed_tests;
    integer failed_tests;
    integer total_tests;
    
    // Memory monitoring
    reg [7:0] expected_value;
    reg [7:0] actual_value;
    
    // Clock generation (50MHz -> 20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    // VCD dump for waveform viewing
    initial begin
        $dumpfile("interrupt_tb.vcd");
        $dumpvars(0, interrupt_tb);
    end
    
    // Instantiate the processor
    top uut (
        .clk(clk),
        .rst(rst),
        .In_port(In_port),
        .int(interrupt),
        .Out_port(Out_port),
        .HLT(HLT_Flag)
    );
    
    //==========================================================================
    // TASK 1: Initialize Test Environment
    //==========================================================================
    task initialize_test;
        begin
            passed_tests = 0;
            failed_tests = 0;
            total_tests = 0;
            rst = 1;
            In_port = 8'h00;
            interrupt = 0;
            wait_cycles(2);
            $display("\n========================================");
            $display("  PROCESSOR TESTBENCH STARTED");
            $display("========================================\n");
        end
    endtask
    
    //==========================================================================
    // TASK 2: Initialize Register File
    //==========================================================================
    task initialize_regfile;
    begin
       // Initialize registers
        uut.regFile.file[0] = 8'hFF;
        uut.regFile.file[1] = 8'h02;
        uut.regFile.file[2] = 8'h04;
        uut.regFile.file[3] = 8'h7f;
    end
    endtask

    //==========================================================================
    // TASK 3: Loading From Assembler
    //==========================================================================
    task load_hex_file;
    input [100*8:1] filename;
    begin
        $readmemh(filename, uut.u_Memory.Mem);
        $display("[INFO] Loaded program from %0s", filename);
    end
    endtask
    

    //==========================================================================
    // TASK 4: Wait for Clock Cycles
    //==========================================================================
    task wait_cycles;
        input integer num_cycles;
        begin
            repeat(num_cycles) @(posedge clk);
        end
    endtask

    //==========================================================================
    // TASK 5: Check Register Value
    //==========================================================================
    task check_register;
        input [1:0] reg_num;
        input [7:0] expected;
        input [100*8:1] test_name;
        reg [7:0] actual;
        begin
            total_tests = total_tests + 1;
            
            actual = uut.regFile.file[reg_num];
            
            if (actual === expected) begin
                $display("[PASS] %0s: R%0d = 0x%0h (Expected: 0x%0h)", 
                         test_name, reg_num, actual, expected);
                passed_tests = passed_tests + 1;
            end else begin
                $display("[FAIL] %0s: R%0d = 0x%0h (Expected: 0x%0h)", 
                         test_name, reg_num, actual, expected);
                failed_tests = failed_tests + 1;
            end
        end
    endtask

    //==========================================================================
    // TASK 6: Check Flag Value
    //==========================================================================
    task check_flag;
    input [1:0] flag_type; // 0=Z, 1=N, 2=C, 3=V
    input expected;
    input [100*8:1] test_name;
    reg actual;
    reg [7:0] f_name; // To store string name of flag
    begin
        total_tests = total_tests + 1;

        case(flag_type)
            2'b00: begin actual = uut.CCR_out[0]; f_name = "Z"; end
            2'b01: begin actual = uut.CCR_out[1]; f_name = "N"; end
            2'b10: begin actual = uut.CCR_out[2]; f_name = "C"; end
            2'b11: begin actual = uut.CCR_out[3]; f_name = "V"; end
            default: actual = 1'bx;
        endcase

        if (actual === expected) begin
            $display("[PASS] %s: %s Flag = %b (Expected: %b)", 
                     test_name, f_name, actual, expected);
            passed_tests = passed_tests + 1;
        end else begin
            $display("[FAIL] %s: %s Flag = %b (Expected: %b) !!!", 
                     test_name, f_name, actual, expected);
            failed_tests = failed_tests + 1;
        end
    end
endtask

    //==========================================================================
    // TASK 7: Check Memory Value
    //=========================================================================
    task check_memory;
        input [7:0] addr;
        input [7:0] expected;
        input [100*8:1] test_name;
        reg [7:0] actual;
        begin
            total_tests = total_tests + 1;
            actual = uut.u_Memory.Mem[addr];
            
            if (actual === expected) begin
                $display("[PASS] %0s: MEM[0x%0h] = 0x%0h (Expected: 0x%0h)", 
                         test_name, addr, actual, expected);
                passed_tests = passed_tests + 1;
            end else begin
                $display("[FAIL] %0s: MEM[0x%0h] = 0x%0h (Expected: 0x%0h)", 
                         test_name, addr, actual, expected);
                failed_tests = failed_tests + 1;
            end
        end
    endtask

    //==========================================================================
    // TASK 8: Apply Reset
    //==========================================================================
    task apply_reset;
        input integer cycles;
        begin
            $display("[%0t] Applying Reset for %0d cycles...", $time, cycles);
            rst = 0;
            repeat(cycles) @(negedge clk);
            rst = 1;
            @(posedge clk);
            $display("[%0t] Reset Released", $time);
        end
    endtask

    //==========================================================================
    // TASK 9: Test Reset Functionality
    //==========================================================================
    task test_reset;
        begin
            $display("\n========================================");
            $display("  TESTING RESET FUNCTIONALITY");
            $display("========================================");
            
            // Setup: Load reset vector at memory location 0
            uut.u_Memory.Mem[0] = 8'h02; // Start at address 0x02
            
            // Apply reset
            apply_reset(3);
            
            wait_cycles(3);

            total_tests = total_tests + 1;
            if (uut.PC === uut.u_Memory.Mem[0]) begin
                $display("[PASS] PC loaded from reset vector");
                passed_tests = passed_tests + 1;
            end else begin
                $display("[FAIL] PC not loaded correctly from reset vector");
                failed_tests = failed_tests + 1;
            end
        end
    endtask

    
    //==========================================================================
    // TASK 10: Check Output Port
    //==========================================================================
    task check_output_port;
        input [7:0] expected;
        input [100*8:1] test_name;
        begin
            total_tests = total_tests + 1;
            
            if (Out_port === expected) begin
                $display("[PASS] %0s: OUT_PORT = 0x%0h (Expected: 0x%0h)", 
                         test_name, Out_port, expected);
                passed_tests = passed_tests + 1;
            end else begin
                $display("[FAIL] %0s: OUT_PORT = 0x%0h (Expected: 0x%0h)", 
                         test_name, Out_port, expected);
                failed_tests = failed_tests + 1;
            end
        end
    endtask

    //==========================================================================
    // TASK 11: Check PC
    //==========================================================================
    task check_PC;
    input [7:0] expected;
    input [80*8:1] message;
    reg [7:0] actual;
    begin
        total_tests = total_tests + 1;
        actual = uut.PC;

        if (actual == expected)begin
            $display("[PASS] %0s: PC = 0x%0h (Expected: 0x%0h)", 
                         message, actual , expected);
            passed_tests = passed_tests + 1;             
        end else begin 
             $display("[FAIL] %0s: PC = 0x%0h (Expected: 0x%0h)", 
                         message, actual , expected);
            failed_tests = failed_tests + 1;
        end
    end
    endtask

    //==========================================================================
    // TASK 12: Print Test Summary
    //==========================================================================
    task print_summary; begin
                        
            $display("\n========================================");
            $display("  TEST SUMMARY");
            $display("========================================");
            $display("Total Tests:  %0d", total_tests);
            $display("Passed:       %0d", passed_tests);
            $display("Failed:       %0d", failed_tests);
            $display("========================================\n");
            
            if (failed_tests == 0) begin
                $display("*** ALL TESTS PASSED! ***\n");
            end else begin
                $display("*** SOME TESTS FAILED ***\n");
            end
        end
    endtask

    //==========================================================================
    // TASK 13: Load Instruction Memory
    //==========================================================================
    task load_instruction_memory;
        input [7:0] addr;
        input [7:0] data;
        begin
            // Access processor's memory - adjust path based on your hierarchy
            uut.u_Memory.Mem[addr] = data;
        end
    endtask

    //==========================================================================
    // TASK 14: Clear Memory
    //==========================================================================
    task clear_memory;
        integer i;
        begin
            for (i = 0; i < 256; i = i + 1) begin
                    uut.u_Memory.Mem[i] = 8'h00;
            end
        end
    endtask
    
    
    //==========================================================================
    // MAIN TEST SEQUENCE
    //==========================================================================
    initial begin
        clear_memory();

        load_instruction_memory(8'd00,8'd02);
        load_instruction_memory(8'd01,8'hB0);  
        load_instruction_memory(8'd02,8'hC2);  //LDM R2, 0x05
        load_instruction_memory(8'd03,8'h05);  
        load_instruction_memory(8'd04,8'h26);  //ADD R1,R2
        load_instruction_memory(8'd05,8'h36);  //SUB R1,R2

        load_instruction_memory(8'hB0,8'h35);  //SUB R1,R1
        load_instruction_memory(8'hB1,8'h59);  //OR  R2,R1
        load_instruction_memory(8'hB2,8'hBC);  //RTI
       

        initialize_test();
        initialize_regfile();
        apply_reset(3);
        
        $display("\n========================================");
        $display("  STARTING INSTRUCTION TESTS");
        $display("========================================\n");

        //==================================================================
        // A-FORMAT TEST CASES
        //==================================================================
        // TEST 0: Reset
        $display("--- TEST 0: RESET ---");
        check_PC(8'h02, "Reset loads PC from M[0]");
        interrupt = 1'b1 ; //rise interrrupt
        wait_cycles(1);


        //I1: LDM R2,0x05
        $display("\n--- TEST 1: LDM ---");
        wait_cycles(3);
        check_register(2'b10, 8'h05, "LDM R2, 0x05");

        
        check_PC(8'hB0, "interrupt jumbs to the ISR");
        
        interrupt = 1'b0 ; 
        // TEST 2: ADD R1, R2
        $display("\n--- TEST 2: ADD ---");
        wait_cycles(1);
        
        // wait_cycles(1);
        check_flag(2'b00, 1'b0, "ADD Z flag");
        check_flag(2'b10, 1'b0, "ADD C flag");
        wait_cycles(1);
        check_register(2'b01, 8'h07, "ADD R1, R2 (2+5=7 & C_flag=0)");
        

        // TEST 3: SUB R1, R1
        $display("\n--- TEST 3:1st I in ISR SUB ---");
        wait_cycles(1);
        check_flag(2'b00, 1'b1, "SUB Z flag");
        wait_cycles(1);
        check_register(2'b01, 8'h00, "SUB R1, R1 (7-7=0)");


        //TEST4: OR R2, R1
        $display("\n--- TEST 4: OR ---");
        wait_cycles(1);
        check_register(2'b10, 8'h05, "OR R2, R1 (5 | 0 = 5)");

        //TEST5: RTI 
        $display("\n--- TEST 5: RTI ---");
        wait_cycles(1);
        check_PC(8'd05, "RTI returns to where it jumbed");


        // TEST 6: SUB R1, R2
        $display("\n--- TEST 3: SUB ---");
        wait_cycles(3);
        check_flag(2'b00, 1'b0, "SUB Z flag");
        check_flag(2'b01, 1'b1, "SUB N flag");
        wait_cycles(1);
        check_register(2'b01, 8'hFB, "SUB R1, R2 (0-5=-5)");


        wait_cycles(5);
        print_summary();
        $stop;

    end
endmodule