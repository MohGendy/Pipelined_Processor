module top (
    input  wire clk,
    input  wire rst,
    input  wire int,
    input  wire [7:0] In_port,

    output wire hlt,
    output wire [7:0] Out_port
);

//! wires
//? fetch
    wire pc_src    ;
    wire data_out  ;
    wire reg_rb_d  ;
    wire I_data    ;
    wire reg_rb_ex ;
    wire pc_in     ;

    wire pc_load ;
    wire pc_en   ;
    wire PC      ;

    wire addr_src ;
    wire I_addr   ;

    wire sf1     ;
    wire SM1_out ;

    wire flush_IR;
    wire reg_sf1 ;
    wire IR      ;

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
    .out (SM1_out)
);

instruction_reg IR(
    .clk     (clk     ),
    .rst     (rst     ),
    .flush   (flush_IR),
    .sf1_in  (sf1     ),
    .ir_new  (SM1_out ),
    .reg_sf1 (reg_sf1 ),
    .ir      (IR      )
);






endmodule