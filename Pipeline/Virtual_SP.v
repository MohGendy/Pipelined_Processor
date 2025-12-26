module SP_Unit (
    input wire       clk,
    input wire       rst,

    input wire       stall,         // stall from hazard unit

    input wire [7:0] SP,            // RD_A output of regfile direct
    input wire [7:0] ALU_res,       // output of alu after mux ME3
    input wire [7:0] D_data,      // Data out of the memory
    input wire [7:0] data_to_CPU,

    input wire [1:0] SP_Ex,

    input wire       we_Ex,         // Write Enable: Is the instruction writing to RegFile?
    input wire       sw1_Ex,        // Select Write Address: 0 for Ra, 1 for Rb (Destination)
    input wire [1:0] ra_Ex,         // Ra address passed to MEM stage
    input wire [1:0] rb_Ex,         // Rb address passed to MEM stage
    input wire       sm2_Ex,        // Memory Mux Select: 0 = Pass ALU Result, 1 = Load from Memory
    input wire       sw2_Ex,        //  Write Data Mux: 0 = Memory/ALU Data, 1 = Input Port Wire but for memory stage

    input wire       we_M,          // Write Enable: Is the instruction writing to RegFile?
    input wire       sw1_M,         // Select Write Address: 0 for Ra, 1 for Rb (Destination)
    input wire [1:0] ra_M,          // Ra address passed to MEM stage
    input wire [1:0] rb_M,          // Rb address passed to MEM stage
    input wire       sm2_M,         // Memory Mux Select: 0 = Pass ALU Result, 1 = Load from Memory
    input wire       sw2_M,         //  Write Data Mux: 0 = Memory/ALU Data, 1 = Input Port Wire but for memory stage

    input wire       we_Wb,         // Write Enable: Is the instruction writing to RegFile?
    input wire       sw1_Wb,        // Select Write Address: 0 for Ra, 1 for Rb (Destination)
    input wire [1:0] ra_Wb,         // Ra address passed to MEM stage
    input wire [1:0] rb_Wb,         // Rb address passed to MEM stage
    input wire       sw2_Wb,        //  Write Data Mux: 0 = Memory/ALU Data, 1 = Input Port Wire but for memory stage

    output     [7:0] Bypassed_SP,
    output           Not_Ready


);

    reg  [7:0] virtual_SP ;
    reg  [7:0] BypassOut ;
    reg        Invalid ;

    wire [1:0] target_Ex;
    wire [1:0] target_M;
    wire [1:0] target_Wb;
    reg        sel;

    assign target_Ex = sw1_Ex? rb_Ex : ra_Ex;    
    assign target_M  = sw1_M?  rb_M  : ra_M;
    assign target_Wb = sw1_Wb? rb_Wb : ra_Wb; 

    assign Not_Ready = Invalid;
    assign Bypassed_SP = sel?data_to_CPU:BypassOut;

    always @(posedge clk or negedge rst) begin //? manage sync opertation
        if(!rst) begin
            virtual_SP <= SP;
        end
        else if (!stall) begin
            if (SP_Ex[1] &! Invalid) virtual_SP <= BypassOut + 8'd1;
            else if (SP_Ex[0] &! Invalid) virtual_SP <= BypassOut - 8'd1;
            else  virtual_SP <= BypassOut ;
        end 

    end

    always @(*) begin //? manage async opertation
        sel = 1'b0;
        Invalid = 1'b0;
        if (!rst)
            BypassOut = SP;
        else if (we_Ex & (&target_Ex)) begin //* bitwise and => target = 11 
            BypassOut = virtual_SP; //!default
            if ((~sw2_Ex) & (~sm2_Ex)) begin
                BypassOut = ALU_res;
                Invalid = 1'b0;
            end
            else begin
                BypassOut = virtual_SP;
                Invalid = 1'b1;
            end

        end
        else if (we_M & (&target_M)) begin //* bitwise and => target = 11 
            BypassOut = virtual_SP; //!default
            if ((~sw2_M) & (sm2_M)) begin
                BypassOut = D_data;
                Invalid = 1'b1;
            end
            else if ((~sw2_M) & (~sm2_M)) begin
                BypassOut = virtual_SP;
                Invalid = 1'b0;
            end
            else begin
                BypassOut = virtual_SP;
                Invalid = 1'b1;
            end

        end
        else if (we_Wb & (&target_Wb)) begin //* bitwise and => target = 11 
            BypassOut = virtual_SP; //!default
            if ((sw2_Wb)) begin
                BypassOut = data_to_CPU;
                Invalid = 1'b0;
                sel = 1'b1;
            end
            else begin
                BypassOut = virtual_SP;
                Invalid = 1'b0;
            end

        end

    end
    
endmodule