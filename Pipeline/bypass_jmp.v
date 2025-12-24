module bypass_jmp(

    // 0 = JMP, 1 = CALL
    input wire [7:0] IR, 

    // From EX (previous instruction)
    input wire       we_Ex,         // Write Enable: Is the instruction writing to RegFile?
    input wire       sw1_Ex,        // Select Write Address: 0 for Ra, 1 for Rb (Destination)
    input wire [1:0] ra_Ex,         // Ra address passed to MEM stage
    input wire [1:0] rb_Ex,         // Rb address passed to MEM stage
    input wire       sm2_Ex,        // Memory Mux Select: 0 = Pass ALU Result, 1 = Load from Memory
    input wire       sw2_Ex,        //  Write Data Mux: 0 = Memory/ALU Data, 1 = Input Port Wire but for memory stage

    // From MEM (before previous instruction)
    input wire       we_mem,         // Write Enable: Is the instruction writing to RegFile?
    input wire       sw1_mem,        // Select Write Address: 0 for Ra, 1 for Rb (Destination)
    input wire [1:0] ra_mem,         // Ra address passed to MEM stage
    input wire [1:0] rb_mem,         // Rb address passed to MEM stage
    input wire       sw2_mem,        //  Write Data Mux: 0 = Memory/ALU Data, 1 = Input Port Wire but for memory stage

    // stall request in Fetch/Decode
    output reg stall_d,
    output reg [1:0] SHD // 0 => no bypass , 1 => alu res , 2 => Data out
);

    reg [1:0] dest_mem;
    reg [1:0] dest_Ex;
    wire [1:0] rb;
    
    wire jmp_or_call;

    assign jmp_or_call = (IR[7:4] == 4'd11 &! IR[3]);
    assign rb = IR[1:0];
    always @(*) begin
        stall_d = 1'b0;      // No stall by default
        SHD = 2'b00;        // no bypass bt default

        if(jmp_or_call) begin
            
            if (sw1_mem == 1'b0) 
                dest_mem = ra_mem;
            else 
                dest_mem = rb_mem;

            if (sw1_Ex == 1'b0) 
                dest_Ex = ra_Ex;
            else 
                dest_Ex = rb_Ex;


            if(we_Ex && (dest_Ex == rb)) begin
                if (sw2_Ex | sm2_Ex)
                    stall_d = 1'b1;
                else
                    SHD = 2'b01;
            end
            else if(we_mem && (dest_mem == rb)) begin
                if (sw2_mem) 
                    stall_d = 1'b1;
                else
                    SHD = 2'b10;
            end

        end

    end

endmodule
