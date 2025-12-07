`timescale 1ns/1ps
 module ALU_TB ();

reg  [7:0] A_TB , B_TB;
reg  CLK_TB;
reg  [3:0] opcode_TB;
wire [7:0] ALU_OUT_TB;
wire Zero_Flag_TB;
wire Negative_Flag_TB;
wire Carry_Flag_TB;
wire Overflow_TB;

//INSTANTIATION
ALU DUT (
    .A(A_TB),
    .B(B_TB),
    .CLK(CLK_TB),
    .opcode(opcode_TB),
    .ALU_OUT(ALU_OUT_TB),
    .Zero_Flag(Zero_Flag_TB),
    .Negative_Flag(Negative_Flag_TB),
    .Carry_Flag(Carry_Flag_TB),
    .Overflow(Overflow_TB)
);

// Parameters
parameter CLK_PERIOD = 10;  // 100 KHz

//CLOCK GENERATOR   
always #(CLK_PERIOD/2)
CLK_TB = ~CLK_TB;

initial begin
   $dumpfile("ALU.vcd");
    $dumpvars;

        // Initial values
        CLK_TB = 1'b0;
        // TEST CASE 1: NOP
        $display("*** TEST CASE 1 : NOP ***");
        A_TB = 8'h00;
        B_TB = 8'h00;
        opcode_TB = 4'b0000;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'h00)
            $display("NOP IS PASSED");
        else
            $display("NOP IS FAILED");

        // TEST CASE 2: Addition With Carry
        $display("*** TEST CASE 2 : Addition With Carry ***");
        A_TB = 8'hFF;
        B_TB = 8'h02;
        opcode_TB = 4'b0010;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'h01 && Carry_Flag_TB == 1'b1)
            $display("Addition With Carry IS PASSED");
        else
            $display("Addition With Carry IS FAILED");

        // TEST CASE 3: Addition With Overflow
        $display("*** TEST CASE 3 : Addition With Overflow ***");
        A_TB = 8'h7F;
        B_TB = 8'h01;
        opcode_TB = 4'b0010;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'h80 && Overflow_TB == 1'b1)
            $display("Addition With Overflow IS PASSED");
        else
            $display("Addition With Overflow IS FAILED");

        // TEST CASE 4: Subtraction Without Borrow
        $display("*** TEST CASE 4 : Subtraction Without Borrow ***");
        A_TB = 8'd15;
        B_TB = 8'd10;
        opcode_TB = 4'b0011;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'd5 && Carry_Flag_TB == 1'b0)
            $display("Subtraction Without Borrow IS PASSED");
        else
            $display("Subtraction Without Borrow IS FAILED");

        // TEST CASE 5: Subtraction With Borrow
        $display("*** TEST CASE 5 : Subtraction With Borrow ***");
        A_TB = 8'd5;
        B_TB = 8'd10;
        opcode_TB = 4'b0011;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'hFB && Carry_Flag_TB == 1'b1)
            $display("Subtraction With Borrow IS PASSED");
        else
            $display("Subtraction With Borrow IS FAILED");

       // TEST CASE 6: AND Operation
        $display("*** TEST CASE 6 : ANDING ***");
        A_TB = 8'hF0;
        B_TB = 8'h0F;
        opcode_TB = 4'b0100;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'h00 && Zero_Flag_TB == 1'b1)
            $display("ANDING IS PASSED");
        else
            $display("ANDING IS FAILED");

        // TEST CASE 7: OR Operation
        $display("*** TEST CASE 7 : ORING ***");
        A_TB = 8'hF0;
        B_TB = 8'h0F;
        opcode_TB = 4'b0101;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'hFF && Negative_Flag_TB == 1'b1)
            $display("ORING IS PASSED");
        else
            $display("ORING IS FAILED");

        // TEST CASE 8: RLC (Rotate Left through Carry)
        $display("*** TEST CASE 8 : RLC ***");
        A_TB = 8'b00;  // ra = 00 for RLC
        B_TB = 8'b10101010;
        opcode_TB = 4'b0110;
        #CLK_PERIOD
        if (Carry_Flag_TB == 1'b1)
            $display("RLC IS PASSED");
        else
            $display("RLC IS FAILED");

        // TEST CASE 9: RRC (Rotate Right through Carry)
        $display("*** TEST CASE 9 : RRC ***");
        A_TB = 8'b01;  // ra = 01 for RRC
        B_TB = 8'b10101010;
        opcode_TB = 4'b0110;
        #CLK_PERIOD
        if (Carry_Flag_TB == 1'b0)
            $display("RRC IS PASSED");
        else
            $display("RRC IS FAILED");

        // TEST CASE 10: SETC
        $display("*** TEST CASE 10 : SETC ***");
        A_TB = 8'b10;  // ra = 10 for SETC
        B_TB = 8'h00;
        opcode_TB = 4'b0110;
        #CLK_PERIOD
        if (Carry_Flag_TB == 1'b1)
            $display("SETC IS PASSED");
        else
            $display("SETC IS FAILED");

        // TEST CASE 11: CLRC
        $display("*** TEST CASE 11 : CLRC ***");
        A_TB = 8'b11;  // ra = 11 for CLRC
        B_TB = 8'h00;
        opcode_TB = 4'b0110;
        #CLK_PERIOD
        if (Carry_Flag_TB == 1'b0)
            $display("CLRC IS PASSED");
        else
            $display("CLRC IS FAILED");

        // TEST CASE 12: NOT Operation
        $display("*** TEST CASE 12 : NOT ***");
        A_TB = 8'b00;  // ra = 00 for NOT
        B_TB = 8'b10101010;
        opcode_TB = 4'b1000;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'b01010101)
            $display("NOT IS PASSED");
        else
            $display("NOT IS FAILED");

        // TEST CASE 13: NEG Operation
        $display("*** TEST CASE 13 : NEG ***");
        A_TB = 8'b01;  // ra = 01 for NEG
        B_TB = 8'd5;
        opcode_TB = 4'b1000;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'hFB && Negative_Flag_TB == 1'b1)
            $display("NEG IS PASSED");
        else
            $display("NEG IS FAILED");

        // TEST CASE 14: INC Operation
        $display("*** TEST CASE 14 : INC ***");
        A_TB = 8'b10;  // ra = 10 for INC
        B_TB = 8'd42;
        opcode_TB = 4'b1000;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'd43)
            $display("INC IS PASSED");
        else
            $display("INC IS FAILED");

        // TEST CASE 15: DEC Operation
        $display("*** TEST CASE 15 : DEC ***");
        A_TB = 8'b11;  // ra = 11 for DEC
        B_TB = 8'd42;
        opcode_TB = 4'b1000;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'd41)
            $display("DEC IS PASSED");
        else
            $display("DEC IS FAILED");

        // TEST CASE 16: Zero Flag Test
        $display("*** TEST CASE 16 : Zero Flag Test ***");
        A_TB = 8'd10;
        B_TB = 8'd10;
        opcode_TB = 4'b0011;  // SUB
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'd0 && Zero_Flag_TB == 1'b1)
            $display("Zero Flag IS PASSED");
        else
            $display("Zero Flag IS FAILED");


 #100
$finish;
end



 endmodule