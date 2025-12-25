module hazard_CU (
    input wire [3:0] opcode,
    input wire [1:0] ra,
    input wire sf1,
    output reg [1:0] has_hazard //1=> a , 0=> b
);
    always @(*) begin 
        if (sf1) begin
            has_hazard = 2'b10;
        end
        casex ( {opcode,ra} )
                            
            6'b0001xx,
            6'b01100x,
            6'b011110,
            6'b1000xx,
            6'b1001xx,
            6'b110010
            : has_hazard = 2'b01;
                            //ab
            6'b101101,
            6'b10111x,
            6'b1101xx
            : has_hazard = 2'b10;
                            //ab
            6'b0000xx,
            6'b01101x,
            6'b011111,
            6'b101100,
            6'b11000x
            : has_hazard = 2'b00;
                            //ab
            default: has_hazard = 2'b11;
        endcase
    end
endmodule