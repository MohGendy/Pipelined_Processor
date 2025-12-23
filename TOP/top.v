module top (
    input  wire clk,
    input  wire rst,
    input  wire int,
    input  wire [7:0] In_port,

    output wire HLT,
    output wire [7:0] Out_port
);

//! wires
//? fetch
    wire [1:0] pc_src    ;
    wire [7:0] data_out  ;
    wire [7:0] reg_rb_d  ;
    wire [7:0] I_data    ;
    wire [7:0] reg_rb_ex ;
    wire [7:0] pc_in     ;

    wire pc_load  ;
    wire pc_en    ;
    wire [7:0] PC ;

    wire [1:0] addr_src ;
    wire [7:0] I_addr   ;

    wire sf1     ;
    wire [7:0] MF1_out ;

    wire flush_IR  ;
    wire reg_sf1   ;
    wire [7:0] IR  ;

//RegFile
    wire RF_WE ;
    wire IncSP ;
    wire DecSP ;
    wire [1:0] RA_addr ;
    wire [1:0] RB_addr ; 
    wire [1:0] RW_addr ;
    wire [7:0] WD ;
    wire [7:0] RD_A ; 
    wire [7:0] RD_B ;

//ALU   
    wire SE2 ;
    wire [7:0] ME2_out ;


//! modules
//? fetch
pc_in_mux u_pc_in_mux(
    .pc_src    (pc_src    ),
    .data_out  (data_out  ),
    .reg_rb_d  (reg_rb_d  ),
    .I_out     (I_data    ),
    .reg_rb_ex (reg_rb_ex ),
    .pc_in     (pc_in     )
);

PC u_PC(
    .clk     (clk     ),
    .pc_load (pc_load ),
    .pc_en   (pc_en   ),
    .pc_in   (pc_in   ),
    .pc_out  (PC      )
);

mem_addr_mux u_mem_addr_mux(
    .addr_src (addr_src ),
    .pc       (PC       ),
    .mem_addr (I_addr   )
);

Memory u_Memory(
    .clk    (clk    ),
    .rst    (rst    ),
    .I_addr (I_addr ),
    .D_addr (D_addr ), //!
    .Wdata  (Wdata  ), //!
    .WEn    (WEn    ), //!
    .I_data (I_data ), 
    .D_data (D_data )  //!
);

mux_2to1 MF1(
    .sel (sf1    ),
    .in0 (I_data ),
    .in1 (PC     ),
    .out (MF1_out)
);

instruction_reg IR(
    .clk     (clk     ),
    .rst     (rst     ),
    .flush   (flush_IR),
    .sf1_in  (sf1     ),
    .ir_new  (MF1_out ),
    .reg_sf1 (reg_sf1 ),
    .ir      (IR      )
);

regfile regFile (
    .clk(clk),
    .WE(RF_WE),
    .IncSP(IncSP),
    .DecSP(DecSP),
    .RA_addr(RA_addr),
    .RB_addr(RB_addr),
    .RW_addr(RW_addr),
    .WD(WD),
    .RD_A(RD_A),
    .RD_B(RD_B)
);




mux_2to1 ME2(
    .sel (SE2    ),
    .in0 (RD_B   ),
    .in1 (8'b1   ),
    .out (ME2_out)
);




endmodule