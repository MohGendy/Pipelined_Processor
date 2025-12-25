// to do (for gendy) : stack pointer case

/* Module: Hazard and Forwarding Unit
    Description: 
    This unit detects data dependencies between the current instruction in Execute stage (ID/EX)
    and previous instructions in Memory (EX/MEM) and Write-Back (MEM/WB) stages.
    
    It generates:
    1. Forwarding signals (2 bits) for Ra and Rb to bypass data from later stages.
    2. Stall signal (1 bit) to freeze the pipeline if a Load-Use hazard is detected.
    
    Output Codes for Forwarding:
    0: No bypass (Use Register File value).
    1: Bypass from Memory Stage Input (ALU Result from previous instruction).
    2: Bypass from Write-Back Stage (Memory Out / ALU Result).
    3: Bypass from Write-Back Stage (Input Port).
*/

module hazard_forwarding_unit (
    input [1:0] has_hazard,
    // Inputs from Current Stage (ID/EX) - The instruction needing data
    input [1:0] ra_ex,          // Address of Source Register A
    input [1:0] rb_ex,          // Address of Source Register B

    // Inputs from Memory Stage (EX/MEM) - The previous instruction
    input       we_mem,         // Write Enable: Is the instruction writing to RegFile?
    input       sw1_mem,        // Select Write Address: 0 for Ra, 1 for Rb (Destination)
    input [1:0] ra_mem,         // Ra address passed to MEM stage
    input [1:0] rb_mem,         // Rb address passed to MEM stage
    input       sm2_mem,         // Memory Mux Select: 0 = Pass ALU Result, 1 = Load from Memory
    input       sw2_mem,        //  Write Data Mux: 0 = Memory/ALU Data, 1 = Input Port Wire but for memory stage


    // Inputs from Write-Back Stage (MEM/WB) - The instruction before previous
    input       we_wb,          // Write Enable
    input       sw1_wb,         // Select Write Address: 0 for Ra, 1 for Rb
    input [1:0] ra_wb,          // Ra address passed to WB stage
    input [1:0] rb_wb,          // Rb address passed to WB stage
    input       sw2_wb,         // Write Data Mux: 0 = Memory/ALU Data, 1 = Input Port Wire

    // Outputs
    output reg        stall,       // 1 if we need to stall the pipeline
    output reg [1:0]  forward_a,   // Forwarding control for Ra
    output reg [1:0]  forward_b    // Forwarding control for Rb
);

    // Internal variables to hold the calculated Destination Address for MEM and WB stages
    reg [1:0] dest_mem;
    reg [1:0] dest_wb;

    always @(*) begin

        // 1. Determine Destination Registers
        // Based on SW1 signal: If SW1 is 0, destination is Ra. If 1, destination is Rb.
        if (sw1_mem == 1'b0) 
            dest_mem = ra_mem;
        else 
            dest_mem = rb_mem;

        if (sw1_wb == 1'b0) 
            dest_wb = ra_wb;
        else 
            dest_wb = rb_wb;

        // 2. Default Values
        stall = 1'b0;      // No stall by default
        forward_a = 2'b00; // No forwarding by default (Source 0)
        forward_b = 2'b00; // No forwarding by default (Source 0)

        // 3. Hazard & Forwarding Logic for RA (Source A)
        
        // Priority 1: Check Dependency with Memory Stage (Most recent instruction)
        if (we_mem && has_hazard[1] && (dest_mem == ra_ex)) begin
            // We have a match in the Memory Stage
            
            // Check SM2 to see if it is a Load operation or just ALU pass-through
            if (sm2_mem | sw2_mem ) begin
                // SM2 = 1 means we are reading from Memory (Load instruction).
                // The data is NOT ready yet in the Execute stage.
                // WE MUST STALL.
                stall = 1'b1; 
            end
            else begin
                // SM2 = 0 means we are passing the input (ALU Result).
                // The data is ready to be forwarded immediately.
                // Output Code 1: Bypass from memory in (ALU Result).
                forward_a = 2'b01;
            end
        end
        // Priority 2: Check Dependency with Write-Back Stage
        else if (we_wb && (dest_wb == ra_ex)) begin
            // We have a match in the Write-Back Stage
            
            // Check SW2 to see source of data (Memory/ALU or Input Port)
            if (sw2_wb == 1'b1) begin
                // SW2 = 1 means data is coming from Input Port Wire.
                // Output Code 3: Bypass from input.
                forward_a = 2'b11; 
            end
            else begin
                // SW2 = 0 means data is coming from Memory Out / Data Out.
                // Output Code 2: Bypass from memory out.
                forward_a = 2'b10;
            end
        end

        // 4. Hazard & Forwarding Logic for RB (Source B)
        // (Same logic as above, but comparing with rb_ex)

        // Priority 1: Check Dependency with Memory Stage
        if (we_mem && has_hazard[0] && (dest_mem == rb_ex)) begin
            if (sm2_mem | sw2_mem ) begin
                // Load-Use Hazard -> Stall
                stall = 1'b1;
            end
            else begin
                // ALU Result available -> Forward Code 1
                forward_b = 2'b01;
            end
        end
        // Priority 2: Check Dependency with Write-Back Stage
        else if (we_wb && (dest_wb == rb_ex)) begin
            if (sw2_wb == 1'b1) begin
                // Input Port Data -> Forward Code 3
                forward_b = 2'b11;
            end
            else begin
                // Memory/ALU Data -> Forward Code 2
                forward_b = 2'b10;
            end
        end
        
    end

endmodule
