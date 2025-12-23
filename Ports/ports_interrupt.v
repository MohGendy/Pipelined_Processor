/* I/O Ports + external interrupt + a latch so the interrupt is remembered until the CU explicitly clears it. (Don't forget to check _REMINDER_'s*/ 
module ports_interrupt (
  
input clk,   // system clock         
input rst,  // reset (active Low)        
/* OUTSIDE CPU ports */
input [7:0] in_port,                   // data in  
output reg [7:0] out_port,            // data out
input intr,                          // external interrupt  
output reg HLT ,                    // output flag = 1 when hlt , and 0 otherwise      
/* INSIDE CPU ports interface */
input out_en,                     // asserted when executing OUT instruction 
input HLT_en,                    // signal from CU to rise hlt flag
input [7:0] data_from_cpu,      // data to be written to output port
output reg [7:0] data_to_cpu,  // data to be read by CPU
/* Interrupt flag interface */

output reg intr_flag,        // interrupt flag responsible for CPU decision making (when = 1 : "an interrupt happened and still pending")
input intr_clear            // asserted to clear interrupt flag
);

// Latched internal interrupt flag that's stored inside our module

    /* Sequential logic: OUT port register + interrupt flag + HLT flag*/
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            out_port    <= 8'b0;
            data_to_cpu <= 8'b0;
            intr_flag   <= 1'b0;
            HLT_flag    <= 1'b0;
        end else begin
		// OUT instruction
        	if (out_en) out_port <= data_from_cpu;
		
		// Interrupt latching
            if (intr) intr_flag <= 1'b1;
            else if (intr_clear) intr_flag <= 1'b0;
        
        // In port reading
            data_to_cpu <= in_port;

        //HLT port
            if (HLT_en)  HLT_flag <= 1'b1 ;
        end
    end

endmodule
