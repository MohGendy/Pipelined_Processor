`timescale 1ns/1ps
module ALU_TB ();

integer test_count = 15 ;
integer test_num = 1 ;
integer succeeded = 0 ;

reg  clk_TB;
reg  Carry_Flag_IN_TB;
reg  [7:0] A_TB , B_TB;
reg  [3:0] ALU_CONTROL_TB;
wire [7:0] ALU_OUT_TB;
wire Zero_Flag_TB;
wire Negative_Flag_TB;
wire Carry_Flag_OUT_TB;
wire Overflow_TB;

//INSTANTIATION
ALU DUT (
    .A(A_TB),
    .B(B_TB),
    .ALU_CONTROL(ALU_CONTROL_TB),
    .Carry_Flag_IN(Carry_Flag_IN_TB),
    .ALU_OUT(ALU_OUT_TB),
    .Zero_Flag(Zero_Flag_TB),
    .Negative_Flag(Negative_Flag_TB),
    .Carry_Flag_OUT(Carry_Flag_OUT_TB),
    .Overflow(Overflow_TB)
);

// Parameters
parameter CLK_PERIOD = 10;  // 100 KHz

//CLOCK GENERATOR   
always #(CLK_PERIOD/2)
     clk_TB = ~clk_TB;

initial begin
   $dumpfile("ALU.vcd");
   $dumpvars;
        //initial values
        clk_TB = 1'b0 ;
        Carry_Flag_IN_TB = 1'b0 ;

        // TEST CASE 1: Addition With Carry
        $display("*** TEST CASE 1 : Addition With Carry ***");
        A_TB = 8'hFF;
        B_TB = 8'h02;
        ALU_CONTROL_TB = 4'b0010;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'h01 && Carry_Flag_OUT_TB == 1'b1) begin
            $display("Addition With Carry IS PASSED");
            succeeded = succeeded + 1 ;
        end
        else
            $display("Addition With Carry IS FAILED , ALU_OUT = %h , Carry_Flag = %b" , ALU_OUT_TB , Carry_Flag_OUT_TB );


        test_num = test_num + 1 ;
        // TEST CASE 2: Addition With Overflow
        $display("*** TEST CASE 2 : Addition With Overflow ***");
        A_TB = 8'h7F;
        B_TB = 8'h01;
        ALU_CONTROL_TB = 4'b0010;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'h80 && Overflow_TB == 1'b1) begin
            $display("Addition With Overflow IS PASSED");
            succeeded = succeeded + 1 ;
        end
        else
            $display("Addition With Overflow IS FAILED  , ALU_OUT = %h , Overflow = %b" , ALU_OUT_TB , Overflow_TB );

        test_num = test_num + 1 ;
        // TEST CASE 3: Subtraction Without Borrow
        $display("*** TEST CASE 3 : Subtraction Without Borrow ***");
        A_TB = 8'd15;
        B_TB = 8'd10;
        ALU_CONTROL_TB = 4'b0011;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'd5 && Carry_Flag_OUT_TB == 1'b0) begin
            $display("Subtraction Without Borrow IS PASSED");
            succeeded = succeeded + 1 ;
        end
        else
            $display("Subtraction Without Borrow IS FAILED  , ALU_OUT = %h , Carry_Flag = %b" , ALU_OUT_TB , Carry_Flag_OUT_TB );

        test_num = test_num + 1 ;
        // TEST CASE 4: Subtraction With Borrow
        $display("*** TEST CASE 4 : Subtraction With Borrow ***");
        A_TB = 8'd5;
        B_TB = 8'd10;
        ALU_CONTROL_TB = 4'b0011;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'hFB && Carry_Flag_OUT_TB == 1'b1) begin
            $display("Subtraction With Borrow IS PASSED");
            succeeded = succeeded + 1 ;
        end
        else
            $display("Subtraction With Borrow IS FAILED , ALU_OUT = %h , Carry_Flag = %b" , ALU_OUT_TB , Carry_Flag_OUT_TB );

        test_num = test_num + 1 ;
       // TEST CASE 5: AND Operation
        $display("*** TEST CASE 5 : ANDING ***");
        A_TB = 8'hF0;
        B_TB = 8'h0F;
        ALU_CONTROL_TB = 4'b0100;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'h00 && Zero_Flag_TB == 1'b1) begin
            $display("ANDING IS PASSED");
            succeeded = succeeded + 1 ;
        end
        else
            $display("ANDING IS FAILED , ALU_OUT = %h , Zero_Flag = %b" , ALU_OUT_TB , Zero_Flag_TB );

        test_num = test_num + 1 ;
        // TEST CASE 6: OR Operation
        $display("*** TEST CASE 6 : ORING ***");
        A_TB = 8'hF0;
        B_TB = 8'h0F;
        ALU_CONTROL_TB = 4'b0101;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'hFF && Negative_Flag_TB == 1'b1) begin
            $display("ORING IS PASSED");
            succeeded = succeeded + 1 ;
        end
        else
            $display("ORING IS FAILED , ALU_OUT = %h , Negative_Flag = %b" , ALU_OUT_TB , Negative_Flag_TB );

        test_num = test_num + 1 ;
        // TEST CASE 7: RLC (Rotate Left through Carry)
        $display("*** TEST CASE 7 : RLC ***");
        A_TB = 8'b00;  
        B_TB = 8'b10101010;
        ALU_CONTROL_TB = 4'b0110;
        #CLK_PERIOD
        if (ALU_OUT_TB ==8'b01010100 && Carry_Flag_OUT_TB == 1'b1) begin
            $display("RLC IS PASSED");
            succeeded = succeeded + 1 ;
        end
        else
            $display("RLC IS FAILED , ALU_OUT = %h , Carry_Flag = %b" , ALU_OUT_TB , Carry_Flag_OUT_TB );

        test_num = test_num + 1 ;
        // TEST CASE 8: RRC (Rotate Right through Carry)
        $display("*** TEST CASE 8 : RRC ***");
        A_TB = 8'b01;  
        B_TB = 8'b10101010;
        ALU_CONTROL_TB = 4'b0111;
        #CLK_PERIOD
        if (ALU_OUT_TB ==8'b01010101 && Carry_Flag_OUT_TB == 1'b0) begin
            $display("RRC IS PASSED");
            succeeded = succeeded + 1 ;
        end
        else
            $display("RRC IS FAILED , ALU_OUT = %h , Carry_Flag = %b" , ALU_OUT_TB , Carry_Flag_OUT_TB );

        test_num = test_num + 1 ;
        // TEST CASE 9: SETC
        $display("*** TEST CASE 9 : SETC ***");
        A_TB = 8'b10;  
        B_TB = 8'h00;
        ALU_CONTROL_TB = 4'b1000;
        #CLK_PERIOD
        if (Carry_Flag_OUT_TB == 1'b1) begin
            $display("SETC IS PASSED");
            succeeded = succeeded + 1 ;
        end
        else
            $display("SETC IS FAILED , Carry_Flag = %b" , Carry_Flag_OUT_TB );

        test_num = test_num + 1 ;
        // TEST CASE 10: CLRC
        $display("*** TEST CASE 10 : CLRC ***");
        A_TB = 8'b11;  
        B_TB = 8'h00;
        ALU_CONTROL_TB = 4'b1001;
        #CLK_PERIOD
        if (Carry_Flag_OUT_TB == 1'b0) begin
            $display("CLRC IS PASSED");
            succeeded = succeeded + 1 ;
        end
        else
            $display("CLRC IS FAILED, Carry_Flag = %b" , Carry_Flag_OUT_TB );

        test_num = test_num + 1 ;
        // TEST CASE 11: NOT Operation
        $display("*** TEST CASE 11 : NOT ***");
        A_TB = 8'b00;  
        B_TB = 8'b10101010;
        ALU_CONTROL_TB = 4'b1010;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'b01010101) begin
            $display("NOT IS PASSED");
            succeeded = succeeded + 1 ;
        end
        else
            $display("NOT IS FAILED , ALU_OUT = %h " , ALU_OUT_TB );

        test_num = test_num + 1 ;
        // TEST CASE 12: NEG Operation
        $display("*** TEST CASE 12 : NEG ***");
        A_TB = 8'b01;  
        B_TB = 8'd5;
        ALU_CONTROL_TB = 4'b1011;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'hFB && Negative_Flag_TB == 1'b1) begin
            $display("NEG IS PASSED");
            succeeded = succeeded + 1 ;
        end
        else
            $display("NEG IS FAILED, ALU_OUT = %h , Negative_Flag" , ALU_OUT_TB , Negative_Flag_TB );

        test_num = test_num + 1 ;
        // TEST CASE 13: INC Operation
        $display("*** TEST CASE 13 : INC ***");
        A_TB = 8'b10;  
        B_TB = 8'd42;
        ALU_CONTROL_TB = 4'b1100;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'd43 && Overflow_TB == 1'b0 ) begin
            $display("INC IS PASSED");
            succeeded = succeeded + 1 ;
        end
        else
            $display("INC IS FAILED, ALU_OUT = %h , Overflow_flag = %b " , ALU_OUT_TB , Overflow_TB );

        test_num = test_num + 1 ;
        // TEST CASE 14: DEC Operation
        $display("*** TEST CASE 14 : DEC ***");
        A_TB = 8'b11;  
        B_TB = 8'd42;
        ALU_CONTROL_TB = 4'b1101;
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'd41 && Overflow_TB == 1'b0 ) begin
            $display("DEC IS PASSED");
            succeeded = succeeded + 1 ;
        end
        else
            $display("DEC IS FAILED, ALU_OUT = %h , Overflow_flag = %b " , ALU_OUT_TB , Overflow_TB );

        test_num = test_num + 1 ;
        // TEST CASE 15: Zero Flag Test
        $display("*** TEST CASE 15 : Zero Flag Test ***");
        A_TB = 8'd10;
        B_TB = 8'd10;
        ALU_CONTROL_TB = 4'b0011;  // SUB
        #CLK_PERIOD
        if (ALU_OUT_TB == 8'd0 && Zero_Flag_TB == 1'b1) begin
            $display("Zero Flag IS PASSED");
            succeeded = succeeded + 1 ;
        end
        else
            $display("Zero Flag IS FAILED , ALU_OUT = %h , Zero_Flag = %b" , ALU_OUT_TB , Zero_Flag_TB );


        #(CLK_PERIOD*20) ;
        $display ("*************************************************************************\n");
        $display ("TESTING ENDED , %d out of %d succeeded \n",succeeded , test_count) ;
        $display ("*************************************************************************\n");
$stop;
end



 endmodule