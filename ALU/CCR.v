 module CCR (
    input wire clk,
    input wire rst, 
    input wire [3:0] Flags_in,         // Flags from ALU {V, C, N, Z}
    input wire intr_en,              // Interrupt enable mode
    input wire  Z_Flag_en,           // Enable signals {V_en, C_en, N_en, Z_en}
    input wire  N_Flag_en,  
    input wire  C_Flag_en,  
    input wire  V_Flag_en,  
    output reg [3:0] Flags_out     // Current flags {V, C, N, Z}
);

    // CCR register: [7:4] = Interrupt mode Flags , [3:0] = Normal mode Flags
    reg [7:0] CCR;
    
    always @ (*) begin 
        if (intr_en) Flags_out = CCR [7:4];
        else Flags_out = CCR [3:0];
    end

    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            // Reset: Clear all flags
            CCR <= 8'b0;
        end

        else if (intr_en) begin
            if (V_Flag_en) CCR[7] <= Flags_in[3];  // V flag
            if (C_Flag_en) CCR[6] <= Flags_in[2];  // C flag
            if (N_Flag_en) CCR[5] <= Flags_in[1];  // N flag
            if (Z_Flag_en) CCR[4] <= Flags_in[0];  // Z flag 
        end 

        else begin
            if (V_Flag_en) CCR[3] <= Flags_in[3];  // V flag
            if (C_Flag_en) CCR[2] <= Flags_in[2];  // C flag
            if (N_Flag_en) CCR[1] <= Flags_in[1];  // N flag
            if (Z_Flag_en) CCR[0] <= Flags_in[0];  // Z flag 
        end
    end

endmodule

 
         