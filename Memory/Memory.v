//von neumann memory 
module Memory #(parameter Width = 256 ,addr_width = 8 , Depth = 8 , Data_base = 8'd128) (
    input clk ,
    input [addr_width-1:0] addr1 ,       //code address
    input [addr_width-1:0] addr2 ,      //data address
    input [Depth-1:0] Wdata ,          //write data 
    input WEn ,                       //write enable
    output reg [Depth-1:0] Rdata1 ,  //code data
    output reg [Depth-1:0] Rdata2   //data 
);

reg [Depth-1:0] Mem [Width-1:0] ;

always @(posedge clk) begin
        Rdata1 <= Mem[addr1] ;
        Rdata2 <= Mem[addr2 + Data_base] ;
        if(WEn) begin
            Mem[addr2] <= Wdata ;
        end
end

endmodule