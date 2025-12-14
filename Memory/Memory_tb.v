`timescale 1ns/1ps
module Memory_tb () ;

parameter clk_period = 5 ;

parameter Width = 8'd256 ,addr_width = 8 , Depth = 8 , Data_base = 8'd128 ;

integer test_case = 1 , succeeded = 0 , cases = 3;

reg clk_tb ;
reg [addr_width-1:0] addr1_tb ;       
reg [addr_width-1:0] addr2_tb ;      
reg [Depth-1:0] Wdata_tb ;          
reg WEn_tb ;                     
wire [Depth-1:0] Rdata1_tb ;  
wire [Depth-1:0] Rdata2_tb ;

initial begin
    //initialize 
        $readmemh("hex_numbers.txt",DUT.Mem);
        clk_tb = 1'b0 ;
        addr1_tb = 'h0 ;
        addr2_tb = 'h0 ;
        Wdata_tb = 'b0 ;
        WEn_tb = 1'b0 ;

    #(clk_period*5);

    //test 1 
        if(Rdata1_tb == 'd0) begin
            $display("TEST %d succeeded\n",test_case);
            succeeded = succeeded + 1 ; 
        end
        else $display("TEST %d Failed\n",test_case);

    test_case = test_case + 1 ; 
    #(clk_period*5);

    //test 2 
        if(Rdata2_tb == 'd128) begin
            $display("TEST %d succeeded\n",test_case);
            succeeded = succeeded + 1 ; 
        end
        else $display("TEST %d Failed \n",test_case);
    
    test_case = test_case + 1 ; 
    #(clk_period*5);

    //test 3 
        WEn_tb = 1'b1 ;
        addr2_tb = 'd200 ;
        Wdata_tb = 'd150 ;

        #(clk_period) ;

        WEn_tb = 1'b0 ;

        if(DUT.Mem[200] == 'd150) begin
            $display("TEST %d succeeded\n",test_case);
            succeeded = succeeded + 1 ; 
        end
        else $display("TEST %d Failed \n",test_case);
    

    #(clk_period*10);
    $display("TESTING ENDED %d out of %d succeeded\n",succeeded,cases);
    $stop;
end

//clock generation
    always #(clk_period/2) clk_tb = ~ clk_tb ;

//DUT instantiation
Memory DUT (
    .clk(clk_tb) ,
    .I_addr(addr1_tb) ,
    .D_addr(addr2_tb) ,
    .Wdata(Wdata_tb) ,
    .WEn(WEn_tb) ,
    .I_data(Rdata1_tb) ,
    .D_data(Rdata2_tb)
);

endmodule