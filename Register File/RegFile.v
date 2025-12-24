// Register File Module for the 8-bit Pipelined Processor
// Includes dedicated INC/DEC logic for R3 (Stack Pointer - SP)

module regfile (
    // Clock and Control Signals
    input wire clk,              
    input wire WE,               // Write Enable signal (from WB stage)

    // NEW SP Control Signals
    input wire IncSP,            // Increment SP (R3) signal (for POP/RET/RTI)
    input wire DecSP,            // Decrement SP (R3) signal (for PUSH/CALL/INTR)

    // Read Ports
    input wire [1:0] RA_addr,    
    input wire [1:0] RB_addr,    
    
    // Write Port
    input wire [1:0] RW_addr,    
    input wire [7:0] WD,         
    
    // Output Ports
    output reg [7:0] RD_A,       
    output reg [7:0] RD_B        
);

// Internal Memory Declaration (R0-R3)
reg [7:0] file [0:3];

// ----------------------------------------------------------------------
// Read Logic (Asynchronous Read - UNCHANGED)

always @(*) begin
    // Read data for port A and B immediately
    RD_A = file[RA_addr]; 
    RD_B = file[RB_addr]; 
end

// ----------------------------------------------------------------------
// Write and SP Update Logic (Synchronous Write)

always @(negedge clk) begin
    // 1. Standard Register Write (from WB stage)
    if (WE && RW_addr != 3'b11) begin
        // Perform the standard write if WE is asserted (Writing ALU result, or Data from Memory)
        file[RW_addr] <= WD;

        if (DecSP) begin
            // SP-- (Used by PUSH, CALL, Interrupt)
            // R3 value <- R3 value - 1
            file[3] <= file[3] - 1; 
        end
        
        else if (IncSP) begin
            // ++SP (Used by POP, RET, RTI)
            // R3 value <- R3 value + 1
            file[3] <= file[3] + 1; 
        end
    end
    else if(WE && RW_addr == 3'b11) begin
        file[RW_addr] <= WD;
    end if (!WE) begin
        
        if (DecSP) begin
            // SP-- (Used by PUSH, CALL, Interrupt)
            // R3 value <- R3 value - 1
            file[3] <= file[3] - 1; 
        end
        
        else if (IncSP) begin
            // ++SP (Used by POP, RET, RTI)
            // R3 value <- R3 value + 1
            file[3] <= file[3] + 1; 
        end
    end
    
    // 2. Stack Pointer (R3) Increment/Decrement Logic
    // R3 (file[3]) is the Stack Pointer (SP)
    
    // Priority: If both IncSP and DecSP are asserted (which shouldn't happen), DecSP has priority.
    
end

endmodule
