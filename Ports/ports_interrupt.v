/* I/O Ports + external interrupt + a latch so the interrupt is remembered until the CU explicitly clears it. (Don't forget to check _REMINDER_'s*/ 
module ports_interrupt (
// system clock    
input clk,          
// reset (active Low)
input rst,          

/* OUTSIDE CPU ports */

// data in 
input [7:0] in_port,      
// data out
output reg [7:0] out_port, 
// external interrupt
input intr,         

    
/* INSIDE CPU ports interface */

// asserted when executing OUT instruction
input out_en,                
// data to be written to output port
input [7:0] data_from_cpu,

// data to be read by CPU
// _REMINDER_ : Decide with CU designer if interrupt should be edge-based (rising edge only)
output reg [7:0] data_to_cpu,   

/* Interrupt flag interface */
// interrupt flag responsible for CPU decision making (when = 1 : "an interrupt happened and still pending")
output reg intr_flag,
// asserted to clear interrupt flag
input intr_clear
);

// Latched internal interrupt flag that's stored inside our module

    /* Sequential logic: OUT port register + interrupt flag */
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            out_port <= 8'b00000000;
            data_to_cpu <= 8'b0;
            intr_flag <= 1'b0;
        end else begin
		// OUT instruction
        	if (out_en) out_port <= data_from_cpu;
		
		// Interrupt latching
            if (intr) intr_flag <= 1'b1;
            else if (intr_clear) intr_flag <= 1'b0;
        
        // In port reading
            data_to_cpu <= in_port;
        end
    end

endmodule
