//von neumann memory 
module Memory #(parameter Width = 256 ,addr_width = 8 , Depth = 8 , Data_base = 8'd128) (
    input clk ,
    input [addr_width-1:0] I_addr ,        //instruction address
    input [addr_width-1:0] D_addr ,       //data address
    input [Depth-1:0] Wdata ,            //write data 
    input WEn ,                         //write enable
    output reg [Depth-1:0] I_data ,    //instruction 
    output reg [Depth-1:0] D_data     //data 
);

reg [Depth-1:0] Mem [Width-1:0] ;

always @(posedge clk) begin
        if(WEn) begin
            Mem[D_addr] <= Wdata ;
        end
end

assign I_data = Mem[I_addr] ;
assign D_data = Mem[D_addr + Data_base] ;
endmodule