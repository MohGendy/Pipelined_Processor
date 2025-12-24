`timescale 1ns / 1ps

module Top_tb;

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
        $dumpfile("Top_tb.vcd");
        $dumpvars(0, Top_tb);
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
        uut.regFile.file[2] = 8'h05;
        uut.regFile.file[3] = 8'hFF;
    end
    endtask

    //==========================================================================
    // TASK 3: Loading From Assembler
    //==========================================================================
    task load_hex_file;
    input [200*8:1] filename;
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
        input [200*8:1] test_name;
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
    input [200*8:1] test_name;
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
        input [200*8:1] test_name;
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
        input [200*8:1] test_name;
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
    // TASK 4: Load Instruction Memory
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
    // TASK 2: Clear Memory
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
        load_instruction_memory(8'd0,8'd2);
        load_instruction_memory(8'd1,8'd110);
        load_instruction_memory(8'd2,8'h21);  //ADD R0,R1
        load_instruction_memory(8'd3,8'h19);  //MOV R2,R1
        load_instruction_memory(8'd4,8'h31);  //SUB R0,R1
        load_instruction_memory(8'd5,8'h49);  //AND R2,R1
        load_instruction_memory(8'd6,8'h00);  //NOP
        load_instruction_memory(8'd7,8'h00);  //NOP
        load_instruction_memory(8'd8,8'h00);  //NOP
        load_instruction_memory(8'd9,8'h00);  //NOP
        load_instruction_memory(8'd10,8'h59);  //OR R2,R1
        load_instruction_memory(8'd11,8'h60);  //RLC R0
        load_instruction_memory(8'd12,8'h66);  //RRC R2  
        load_instruction_memory(8'd13,8'h68);  //SETC 1000
        load_instruction_memory(8'd14,8'h6C); //CLRC 1100
        load_instruction_memory(8'd15,8'h78); //OUT R0 1000
        load_instruction_memory(8'd16,8'h7D); //IN R1 1101
        load_instruction_memory(8'd17,8'h82); //NOT R2  0010
        load_instruction_memory(8'd18,8'h84); //NEG R0  0100
        load_instruction_memory(8'd19,8'h89); //INC R1  1001
        load_instruction_memory(8'd20,8'h8E); //DEC R2  1110
        load_instruction_memory(8'd21,8'hC1); //LDM R1, #0x0F
        load_instruction_memory(8'd22,8'h0F); //IMMEDIATE VALUE 
        load_instruction_memory(8'd23,8'hC6); //LDD R2, #0x0B
        load_instruction_memory(8'd24,8'h0B); //IMM
        load_instruction_memory(8'd25,8'hC8); //STD R0, #0x0C 
        load_instruction_memory(8'd26,8'h0C); //IMM
        load_instruction_memory(8'd27,8'hD8); //LDI R2, R0 
        load_instruction_memory(8'd28,8'hE6); //STI R1, R2

        load_instruction_memory(8'd139,8'h50); //DATA MEM[0B] = 50h
        load_instruction_memory(8'd178,8'h40); //DATA MEM[50] = 40h


        initialize_test();
        initialize_regfile();
        // load_hex_file(/*file_name*/);
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
        wait_cycles(1);

        // TEST 1: ADD 
        $display("\n--- TEST 1: ADD ---");
        check_PC(8'h03, "ADD INCREMENTS PC");
        wait_cycles(2);

        check_flag(2'b00, 1'b0, "ADD Z flag");
        check_flag(2'b10, 1'b1, "ADD C flag");
        wait_cycles(1);
        check_register(2'b00, 8'h01, "ADD R0, R1 (255+2=1 & C_flag=1)");
        

        // TEST 2: MOV 
        $display("\n--- TEST 2: MOV ---");
        wait_cycles(1);
        check_register(2'b10, 8'h02, "MOV R2 , R1");

        
        // TEST 3: SUB 
        $display("\n--- TEST 3: SUB ---");
        check_flag(2'b01, 1'b1, "SUB N flag");
        wait_cycles(1);
        check_register(2'b00, 8'hFF, "SUB R0, R1 (1-2=-1)");
        
        
        // TEST 4: AND 
        $display("\n--- TEST 4: AND ---");
        wait_cycles(1);
        check_register(2'b10, 8'h02, "AND R0, R1 (2 & 2 = 2)");

        uut.regFile.file[0] = 8'hAA;
        uut.regFile.file[1] = 8'h02;
        uut.regFile.file[2] = 8'h05;

        wait_cycles(4); //NOPs
        
        //TEST OR 
        $display("\n--- TEST 5: OR ---");
        wait_cycles(1);
        check_register(2'b10, 8'h07, "OR R2, R1 (5 | 2 = 7)");

        //TEST RLC
        $display("\n--- TEST 6: RLC ---");
        check_flag(2'b10, 1'b1, "RLC C flag (MSB was 1)");
        wait_cycles(1);
        check_register(2'b00, 8'h55, "RLC R0 (10101010 -> 01010101)");
        

        //TEST RRC
        $display("\n--- TEST 7: RRC ---");
        check_flag(2'b10, 1'b1, "RRC C flag (LSB was 1)");
        wait_cycles(1);
        check_register(2'b10, 8'h83, "RRC R2 (00000111 -> 10000011)");
        

        //TEST SETC
        $display("\n--- TEST 8: SETC ---");
        check_flag(2'b10, 1'b1, "SETC sets C flag");
        wait_cycles(1);

        //TEST CLRC
        $display("\n--- TEST 9: CLRC ---");
        check_flag(2'b10, 1'b0, "CLRC clears C flag");
        wait_cycles(1);
        

        //TEST OUT
        $display("\n--- TEST 10: OUT ---");
        In_port = 8'hCD;  
        wait_cycles(1);

        //TEST IN
        $display("\n--- TEST 11: IN ---");
        wait_cycles(1); 
        check_output_port(8'h55, "OUT R0 sends 0x55 to Out_port");
        check_register(2'b01, 8'hCD, "IN R1 receives 0xCD from In_port");

        // TEST NOT
        $display("\n--- TEST 12: NOT ---");
        wait_cycles(1);
        check_register(2'b10, 8'h7C, "NOT R2 ( ~(10000011) = 01111100 )");

        // TEST NEG
        $display("\n--- TEST 13: NEG ---");
        wait_cycles(1);
        check_register(2'b00, 8'hAB, "NEG R0 (Two's complement of 0x55 = 0xAB )");

        //TEST INC 
        $display("\n--- TEST 14: INC ---");
        wait_cycles(1);
        check_register(2'b01, 8'hCE, "INC R1 (CD+1=CE)");

        //TEST DEC
        $display("\n--- TEST 15: DEC ---");
        wait_cycles(1);
        check_register(2'b10, 8'h7B, "DEC R2 (7C-1=7B)");

        //==================================================================
        // L-FORMAT TEST CASES
        //==================================================================

        //TEST LDM
        $display("\n--- TEST 16: LDM ---");
        wait_cycles(2);
        check_register(2'b01, 8'h0F, "LDM R1, #0x0F");

        //TEST LDD
        $display("\n--- TEST 17: LDD ---");
        wait_cycles(2);
        check_register(2'b10, 8'h50, "LDD R2, (DATA_MEM[0B]=8'h50)");

        //TEST STD M[12] = R0 = AB
        $display("\n--- TEST 18: STD ---");
        wait_cycles(2);
        check_memory(8'h0C, 8'hAB, "STD MEM[0C], R0 (DATA_MEM[0C]=AB)"); 

        //TEST LDI  R(rb)= M[R(ra)]     ra=2  rb=0 ->   R2=50  R0= M[50] = 40
        $display("\n--- TEST 19: LDI ---");
        wait_cycles(1);
        check_register(2'b00, 8'h40, "LDI R0, ( DATA_MEM[7B]=40)");

        //TEST STI  M[R(ra)] = R(rb)   ra=1  rb=2 -> R1=60  R2=50  MEM[60]=50
        $display("\n--- TEST 20: STI ---");
        wait_cycles(1);
        check_memory(8'h60, 8'h50, "STI MEM[60], R1 (MEM[60]=50)");
        

        wait_cycles(5);
        print_summary();
        $stop;

    end
endmodule