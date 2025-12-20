`timescale 1ns / 1ps

module regfile_tb_full_coverage;

    // ... (Declarations and DUT instantiation remain the same as regfile_tb_sp) ...
    // Note: You must include the declaration and instantiation logic here in your final file.
    
    // Test Bench Inputs (must match your module ports)
    reg clk, WE, IncSP, DecSP;             
    reg [1:0] RA_addr, RB_addr, RW_addr;   
    reg [7:0] WD;        
    wire [7:0] RD_A, RD_B;     
    
    // Instantiate the DUT (Assuming module name is 'regfile')
    regfile DUT (
        .clk(clk), .WE(WE), .IncSP(IncSP), .DecSP(DecSP),
        .RA_addr(RA_addr), .RB_addr(RB_addr), .RW_addr(RW_addr),
        .WD(WD), .RD_A(RD_A), .RD_B(RD_B)
    );
    
    // Clock Generation
    parameter CLK_PERIOD = 20; 
    initial begin clk = 0; forever #(CLK_PERIOD / 2) clk = ~clk; end

    initial begin
        // 1. Initialization and R0 Write
        $display("----------------- FULL COVERAGE TB START ------------------");
        WE = 0; IncSP = 0; DecSP = 0; RA_addr = 0; RB_addr = 0; RW_addr = 0; WD = 8'h00;
        #20; 

        // Test 1: Write to a normal register (R0)
        WE = 1; RW_addr = 2'b00; WD = 8'h11; #CLK_PERIOD; WE = 0;
        $display("Time: %0t - R0 written 0x11", $time);

        // Test 2: Initialize R3 (SP) to 0xFF (255)
        WE = 1; RW_addr = 2'b11; WD = 8'hFF; #CLK_PERIOD; WE = 0;
        $display("Time: %0t - R3 (SP) initialized 0xFF", $time);
        
        // Test 3: Standard Read Check
        RA_addr = 2'b00; RB_addr = 2'b11; 
        #5; // Check asynchronous read
        $display("Time: %0t - Read R0/R3: 0x%h/0x%h", $time, RD_A, RD_B);

        // -----------------------------------------------------------
        // 4. Critical SP Logic Coverage (R3)
        
        // Test 4: DecSP (0xFF -> 0xFE) - Covers DecSP=1 logic
        DecSP = 1; #CLK_PERIOD; DecSP = 0;
        $display("Time: %0t - R3 after Dec: 0x%h. Expected 0xFE", $time, DUT.file[3]);
        
        // Test 5: IncSP (0xFE -> 0xFF) - Covers IncSP=1 logic
        IncSP = 1; #CLK_PERIOD; IncSP = 0;
        $display("Time: %0t - R3 after Inc: 0x%h. Expected 0xFF", $time, DUT.file[3]);
        
        // Test 6: Simultaneous IncSP and DecSP (Should not happen, but covers 'else if')
        // Expected: DecSP takes priority (0xFF -> 0xFE)
        DecSP = 1; IncSP = 1; #CLK_PERIOD; DecSP = 0; IncSP = 0;
        $display("Time: %0t - R3 Inc+Dec: 0x%h. Expected 0xFE (Dec wins)", $time, DUT.file[3]);

        // -----------------------------------------------------------
        // 7. Write Conflict/Priority Coverage
        
        // Test 7: WE Priority (WE=1 should write WD=0xAA, overriding IncSP/DecSP logic)
        // R3: 0xFE -> 0xAA (WE wins)
        WE = 1; DecSP = 1; IncSP = 1; RW_addr = 2'b11; WD = 8'hAA; 
        #CLK_PERIOD; 
        WE = 0; DecSP = 0; IncSP = 0;
        $display("Time: %0t - R3 after WE Priority: 0x%h. Expected 0xAA", $time, DUT.file[3]);
        
        // Test 8: No Operation (WE=0, IncSP=0, DecSP=0) - Covers the implicit 'else'
        #CLK_PERIOD;
        $display("Time: %0t - R3 after NOP: 0x%h. Expected 0xAA (No Change)", $time, DUT.file[3]);

        $display("----------------- FULL COVERAGE TB END --------------------");
        $stop; 
    end

endmodule
