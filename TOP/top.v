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
    wire [7:0] reg_rb_d  ;
    wire [7:0] I_data    ;
    wire [7:0] pc_in     ;

    wire pc_load  ;
    wire pc_en    ;
    wire [7:0] PC ;
    wire PC_en_assigned  ;

    wire [1:0] addr_src ;
    wire [7:0] I_addr   ;

    wire sf1     ;
    wire [7:0] MF1_out ;

    wire flush_IR  ;
    wire reg_sf1   ;
    wire [7:0] IR  ;
    wire ld_IR     ;

    wire bypass_decode_done ;

//? Decode

    wire [1:0] RA_addr ;
    wire [1:0] RB_addr ; 
    wire [7:0] RD_A ; 
    wire [7:0] RD_B ;

    wire SD1 ;

    wire SD2 ;
    wire [7:0] in_RD_A_D ;

    wire [1:0] SD3 ;
    wire [7:0] in_RD_B_D ;

    wire stall ;

    wire stall_d ;

//! CU

    wire [2:0] bu_op ;
    wire Z_Flag_en ;
    wire N_Flag_en ;
    wire C_Flag_en ;
    wire V_Flag_en ;
    wire Wm        ;
    wire SM2       ;
    wire write_en  ;
    wire sw1       ;
    wire sw2       ;
    wire sp_inc    ;
    wire sp_dec    ;
    wire ld_out    ;
    wire HLT_en    ;
    wire stall_CU  ;
    wire int_clr   ;
    wire Int_en    ;
    wire [3:0] ALU_CONTROL ;

    wire [1:0] in_SP ;
    wire [4:0] flags_en ;
    wire ld_D_Ex   ;
    wire flush_D_Ex;

    wire [1:0] ra_Ex      ;
    wire [1:0] rb_Ex      ;
    wire [7:0] R_ra_Ex    ;
    wire [7:0] R_rb_Ex    ;
    wire RW_Ex      ;
    wire [1:0] SP_Ex      ;
    wire SW1_Ex     ;
    wire SW2_Ex     ;
    wire out_ld_Ex  ;
    wire MW_Ex      ;
    wire SM2_Ex     ;
    wire [3:0] ALU_Ex     ;
    wire [4:0] Flags_Ex   ;
    wire [2:0] BU_Ex      ;
    wire SE2_Ex     ;
    wire [1:0] SE3_Ex     ;
    wire Hlt_en_Ex        ;
    wire [1:0] has_hazard;

    wire [1:0] SHD;
    wire [1:0] has_hazard_Ex;

    wire flush_next ;
    
    
//? Excute 

    wire [1:0] SHA;
    wire [7:0] RD_A_Ex;

    wire [1:0] SHB;
    wire [7:0] RD_B_Ex;


    wire SE2 ;
    wire [7:0] ME2_out ;

    wire [7:0] ALU_OUT  ;
    wire Zero_Flag      ;
    wire Negative_Flag  ;
    wire Carry_Flag_OUT ;
    wire Overflow       ;

    wire [3:0] flags_in;

    wire [1:0] SE3 ;
    wire [7:0] Res_EX ;

    wire [3:0] CCR_out;

    wire flush ;

    wire ld_Ex_M    ;
    wire flush_Ex_M ;

    wire [1:0] ra_M       ;
    wire [1:0] rb_M       ;
    wire [7:0] R_rb_M     ;
    wire RW_M       ;
    wire [1:0] SP_M       ;
    wire SW1_M      ;
    wire SW2_M      ;
    wire out_ld_M   ;
    wire MW_M       ;
    wire SM2_M      ;
    wire [7:0] res_M      ;
    wire Hlt_en_M         ;

//? Memory

    wire [7:0] D_data ;

    wire [7:0] DataOut ;

    wire ld_M_Wb    ;
    wire flush_M_Wb ;

    wire [1:0] ra_Wb      ;
    wire [1:0] rb_Wb      ;
    wire RW_Wb      ;
    wire [1:0] SP_Wb      ;
    wire SW1_Wb     ;
    wire SW2_Wb     ;
    wire out_ld_Wb  ;
    wire [7:0] DataOut_Wb ;
    wire Hlt_en_Wb        ;

//? Write back

    wire [1:0] RW_addr ;
    wire [7:0] WD ;

    wire [7:0] data_to_cpu ;

    wire intr_in ;

    wire HLT_out ;
//! assigns

    assign RB_addr  = IR[1:0];
    assign flags_in = {Overflow,Carry_Flag_OUT,Negative_Flag,Zero_Flag};
    assign in_SP    = {sp_inc,sp_dec};
    assign flags_en = {Int_en,Z_Flag_en,N_Flag_en,C_Flag_en,V_Flag_en};
    // assign flush_IR = flush || stall_CU; //! yet to add decode branching Gemyy
    // assign reg_rb_d = RD_B; //! output of bypass decode
    //latches flush/ load
        assign ld_M_Wb    = 1'b1 ;
        assign flush_M_Wb = 1'b0 ;

        assign ld_Ex_M    = 1'b1 ;
        assign flush_Ex_M = stall ; //stall from hazard unit

        assign ld_D_Ex    = !stall ; //stall from hazard unit 
        assign flush_D_Ex = (!stall) & (flush || stall_d || flush_next) ;

        assign ld_IR      = (!stall) & (! stall_d) & (!stall_CU);
        assign flush_IR   = (!stall ) & (flush || ~SD2)   ; //* SD2 added to flush on immediate

        assign bypass_decode_done = ~stall_d ; 
        assign PC_en_assigned = pc_en & ~stall & ~stall_d;

        assign HLT = HLT_out ;
//! modules instantiation
//? fetch
    pc_in_mux u_pc_in_mux( //:)
        .pc_src    (pc_src    ),
        .data_out  (D_data    ), 
        .reg_rb_d  (reg_rb_d  ),
        .I_out     (I_data    ), 
        .reg_rb_ex (RD_B_Ex   ),
        .pc_in     (pc_in     )
    );

    PC u_PC( //:)
        .clk     (clk &! Hlt_en_Ex  ),
        .pc_load (pc_load       ),
        .pc_en   (PC_en_assigned),
        .pc_in   (pc_in         ),
        .pc_out  (PC            )
    );

    mem_addr_mux u_mem_addr_mux( //:)
        .addr_src (addr_src ),
        .pc       (PC       ),
        .mem_addr (I_addr   )
    );

    Memory u_Memory( //:)
        .clk    (clk &! Hlt_en_M ),
        .rst    (rst            ),
        .I_addr (I_addr         ),
        .D_addr (res_M          ),
        .Wdata  (R_rb_M         ), 
        .WEn    (MW_M           ),
        .I_data (I_data         ), 
        .D_data (D_data         )
    );

    mux_2to1 MF1( //:)
        .sel (sf1    ),
        .in0 (I_data ),
        .in1 (PC     ),
        .out (MF1_out)
    );

    instruction_reg IR_u( //:)
        .clk     (clk &! Hlt_en_Ex  ),
        .rst     (rst           ),
        .flush   (flush_IR      ),
        .ld      (ld_IR         ),
        .sf1_in  (sf1           ),
        .ir_new  (MF1_out       ),
        .reg_sf1 (reg_sf1       ),
        .ir      (IR            )
    );

//? Decode 

    regfile regFile ( //:)
        .clk     (clk &! Hlt_en_Wb ),
        .WE      (RW_Wb           ), 
        .IncSP   (SP_Wb[1]        ),
        .DecSP   (SP_Wb[0]        ),
        .RA_addr (RA_addr         ),
        .RB_addr (RB_addr         ),
        .RW_addr (RW_addr         ),
        .WD      (WD              ),
        .RD_A    (RD_A            ),
        .RD_B    (RD_B            )
    );

    mux_2to1 #(.size(2)) MD1 ( //:)
        .sel (SD1     ),
        .in0 (IR[3:2] ),
        .in1 (2'd3    ),
        .out (RA_addr )
    );

    mux_2to1 MD2( //:)
        .sel (SD2       ),
        .in0 (I_data    ), //* imm/ea
        .in1 (RD_A      ),
        .out (in_RD_A_D )
    );

    mux_4to1 MD3( //:)
        .sel (SD3       ),
        .in0 (RD_B      ),
        .in1 (PC        ), //* PC+1 (in call)
        .in2 (IR        ), //* PC+1 (interrupt)
        .in3 (8'b0      ), //* dont care
        .out (in_RD_B_D )
    );

//! CU

    Control_Unit u_Control_Unit(
        .clk                (clk &! Hlt_en_Ex      ),
        .rst                (rst                ),
        .IR                 (IR                 ),
        .reg_sf1            (reg_sf1            ),
        .intr               (intr_in            ),
        .stall_in           (stall              ),
        .branch_taken       (flush              ),
        .bypass_decode_done (bypass_decode_done ), 
        
        .bu_op              (bu_op              ),
        .SE2                (SE2                ),
        .SE3                (SE3                ),
        .ALU_CONTROL        (ALU_CONTROL        ),
        .Z_Flag_en          (Z_Flag_en          ),
        .N_Flag_en          (N_Flag_en          ),
        .C_Flag_en          (C_Flag_en          ),
        .V_Flag_en          (V_Flag_en          ),
        .SD1                (SD1                ), 
        .SD2                (SD2                ), 
        .SD3                (SD3                ), 
        .Wm                 (Wm                 ), 
        .SM2                (SM2                ),
        .write_en           (write_en           ),
        .sw1                (sw1                ),
        .sw2                (sw2                ),
        .sp_inc             (sp_inc             ),
        .sp_dec             (sp_dec             ),
        .ld_out             (ld_out             ),
        .HLT_en             (HLT_en             ),
        .pc_en              (pc_en              ), 
        .pc_load            (pc_load            ),
        .stall              (stall_CU           ),
        .sf1                (sf1                ), 
        .pc_src             (pc_src             ),
        .addr_src           (addr_src           ), 
        .int_clr            (int_clr            ),
        .Int_en             (Int_en             ),
        .has_hazard         (has_hazard         ),
        .flush_next         (flush_next         )
    );

    D_Ex_Latch u_D_Ex_Latch(
        .in_ra          (RA_addr             ),
        .in_rb          (RB_addr             ),
        .in_R_ra        (in_RD_A_D           ),
        .in_R_rb        (in_RD_B_D           ),

        .in_RW          (write_en            ),
        .in_SP          (in_SP               ),
        .in_SW1         (sw1                 ),
        .in_SW2         (sw2                 ),
        .in_out_ld      (ld_out              ),
        .in_MW          (Wm                  ),
        .in_SM2         (SM2                 ),
        .in_ALU         (ALU_CONTROL         ),
        .in_Flags       (flags_en            ),
        .in_BU          (bu_op               ),
        .in_SE2         (SE2                 ),
        .in_SE3         (SE3                 ),
        .in_Hlt         (HLT_en              ),
        .in_has_hazard  (has_hazard          ),
        .clk            (clk &! Hlt_en_Ex    ),
        .reset          (rst                 ),
        .ld             (ld_D_Ex             ),
        .flush          (flush_D_Ex          ),

        .ra             (ra_Ex               ),
        .rb             (rb_Ex               ),
        .R_ra           (R_ra_Ex             ),
        .R_rb           (R_rb_Ex             ),
        .RW             (RW_Ex               ),
        .SP             (SP_Ex               ),
        .SW1            (SW1_Ex              ),
        .SW2            (SW2_Ex              ),
        .out_ld         (out_ld_Ex           ),
        .MW             (MW_Ex               ),
        .SM2            (SM2_Ex              ),
        .ALU            (ALU_Ex              ),
        .Flags          (Flags_Ex            ),
        .BU             (BU_Ex               ),
        .SE2            (SE2_Ex              ),
        .SE3            (SE3_Ex              ),
        .Hlt            (Hlt_en_Ex           ),
        .has_hazard     (has_hazard_Ex       )

    );

    bypass_jmp u_bypass_jmp(
        .IR      (IR      ),
        .we_Ex   (RW_Ex   ),
        .sw1_Ex  (SW1_Ex  ),
        .ra_Ex   (ra_Ex   ),
        .rb_Ex   (rb_Ex   ),
        .sm2_Ex  (SM2_Ex  ),
        .sw2_Ex  (SW2_Ex  ),
        .we_mem  (RW_M    ),
        .sw1_mem (SW1_M   ),
        .ra_mem  (ra_M    ),
        .rb_mem  (rb_M    ),
        .sw2_mem (SW2_M   ),
        .stall_d (stall_d ),
        .SHD     (SHD     )
    );
    
    mux_4to1 MHD(
        .sel (SHD ),
        .in0 (RD_B),
        .in1 (Res_EX ),
        .in2 (DataOut ),
        .in3 (8'b0 ),
        .out (reg_rb_d )
    );
    
//? Excute

    mux_4to1 MHA(//:)
        .sel (SHA         ),
        .in0 (R_ra_Ex     ),
        .in1 (res_M       ),
        .in2 (DataOut_Wb  ),
        .in3 (data_to_cpu ), 
        .out (RD_A_Ex     )
    );

    mux_4to1 MHB(//:)
        .sel (SHB         ),
        .in0 (R_rb_Ex     ),
        .in1 (res_M       ),
        .in2 (DataOut_Wb  ),
        .in3 (data_to_cpu ), 
        .out (RD_B_Ex     )
    );


    mux_2to1 ME2(//:)
        .sel (SE2_Ex  ),
        .in0 (RD_B_Ex ), 
        .in1 (8'b1    ),
        .out (ME2_out )
    );

    ALU u_ALU(//:)
        .A              (RD_A_Ex        ),
        .B              (ME2_out        ),
        .ALU_CONTROL    (ALU_Ex         ),
        .Carry_Flag_IN  (CCR_out[2]     ),
        .ALU_OUT        (ALU_OUT        ),
        .Zero_Flag      (Zero_Flag      ),
        .Negative_Flag  (Negative_Flag  ),
        .Carry_Flag_OUT (Carry_Flag_OUT ),
        .Overflow       (Overflow       )
    );

    mux_4to1 ME3(//:)
        .sel (SE3_Ex ),
        .in0 (ALU_OUT),
        .in1 (RD_A_Ex),
        .in2 (RD_B_Ex),
        .in3 (8'b0   ),
        .out (Res_EX )
    );

    CCR CCReg(//:)
        .clk       (clk &! Hlt_en_Ex    ),
        .rst       (rst                 ), 
        .Flags_in  (flags_in            ), 
        .intr_en   (Flags_Ex[4]         ),            
        .Z_Flag_en (Flags_Ex[3]         ),    
        .N_Flag_en (Flags_Ex[2]         ),  
        .C_Flag_en (Flags_Ex[1]         ),  
        .V_Flag_en (Flags_Ex[0]         ),  
        .Flags_out (CCR_out             )    
    );

    branch_unit BU(//:)
        .bu_op (BU_Ex     ),
        .flags (CCR_out   ),
        .z_now (Zero_Flag ),
        .flush (flush     )
    );

    Ex_M_Latch u_Ex_M_Latch(
        .in_ra     (ra_Ex           ),
        .in_rb     (rb_Ex           ),
        .in_R_rb   (RD_B_Ex         ),
        .in_RW     (RW_Ex           ),
        .in_SP     (SP_Ex           ),
        .in_SW1    (SW1_Ex          ),
        .in_SW2    (SW2_Ex          ),
        .in_out_ld (out_ld_Ex       ),
        .in_MW     (MW_Ex           ),
        .in_SM2    (SM2_Ex          ),
        .in_res    (Res_EX          ),
        .in_Hlt    (Hlt_en_Ex       ),

        .clk       (clk &! Hlt_en_M ),
        .reset     (rst             ),
        .ld        (ld_Ex_M         ),
        .flush     (flush_Ex_M      ),

        .ra        (ra_M            ),
        .rb        (rb_M            ),
        .R_rb      (R_rb_M          ),
        .RW        (RW_M            ),
        .SP        (SP_M            ),
        .SW1       (SW1_M           ),
        .SW2       (SW2_M           ),
        .out_ld    (out_ld_M        ),
        .MW        (MW_M            ),
        .SM2       (SM2_M           ),
        .res       (res_M           ),
        .Hlt       (Hlt_en_M        )
    );

    hazard_forwarding_unit u_hazard_forwarding_unit( //:)
        .ra_ex     (ra_Ex     ),
        .rb_ex     (rb_Ex     ),
        .we_mem    (RW_M      ),
        .sw1_mem   (SW1_M     ),
        .ra_mem    (ra_M      ),
        .rb_mem    (rb_M      ),
        .sm2_mem   (SM2_M     ),
        .sw2_mem   (SW2_M     ),
        .we_wb     (RW_Wb     ),
        .sw1_wb    (SW1_Wb    ),
        .ra_wb     (ra_Wb     ),
        .rb_wb     (rb_Wb     ),
        .sw2_wb    (SW2_Wb    ),
        .stall     (stall     ),
        .forward_a (SHA       ),
        .forward_b (SHB       ),
        .has_hazard(has_hazard_Ex)
    );

//? Memory

    mux_2to1 MM2( //:)
        .sel (SM2_M   ),
        .in0 (res_M   ),
        .in1 (D_data  ),
        .out (DataOut )
    );

    M_WB_Latch u_M_WB_Latch(
        .in_ra      (ra_M               ),
        .in_rb      (rb_M               ),
        .in_RW      (RW_M               ),
        .in_SP      (SP_M               ),
        .in_SW1     (SW1_M              ),
        .in_SW2     (SW2_M              ),
        .in_out_ld  (out_ld_M           ),
        .in_DataOut (DataOut            ),
        .in_Hlt     (Hlt_en_M           ),

        .clk        (clk &! Hlt_en_Wb   ),
        .reset      (rst                ),
        .ld         (ld_M_Wb            ),
        .flush      (flush_M_Wb         ),

        .ra         (ra_Wb              ),
        .rb         (rb_Wb              ),
        .RW         (RW_Wb              ),
        .SP         (SP_Wb              ),
        .SW1        (SW1_Wb             ),
        .SW2        (SW2_Wb             ),
        .out_ld     (out_ld_Wb          ),
        .DataOut    (DataOut_Wb         ),
        .Hlt        (Hlt_en_Wb          )
    );

//? Write back

    mux_2to1 #(.size(2)) MW1( //:)
        .sel (SW1_Wb  ),
        .in0 (ra_Wb   ),
        .in1 (rb_Wb   ),
        .out (RW_addr )
    );

    mux_2to1 MW2( //:)
        .sel (SW2_Wb      ),
        .in0 (DataOut_Wb  ),
        .in1 (data_to_cpu ),
        .out (WD          )
    );

    ports_interrupt ports ( //:)
            .clk            (clk &! HLT_out ),
            .rst            (rst            ),
            .in_port        (In_port        ),
            .intr           (int            ),
            .inter_en       (~Int_en        ),
            .out_en         (out_ld_Wb      ),
            .HLT_en         (Hlt_en_Wb      ),
            .data_from_cpu  (DataOut_Wb     ),
            .intr_clear     (int_clr        ),

            .out_port       (Out_port       ),
            .HLT_flag       (HLT_out        ),
            .data_to_cpu    (data_to_cpu    ),
            .intr_flag      (intr_in        )
        );






endmodule