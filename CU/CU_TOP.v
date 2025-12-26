module Control_Unit (
    input clk ,
    input rst ,                     //active low reset
    input [7:0] IR ,               //the 8bit instruction
    input reg_sf1 ,               //registered interrupt flag
    input intr,                  //registerd interrup signal
    input stall_in,             //signal from hazard unit
    input branch_taken,        //signal from branch unit
    input bypass_decode_done, //signal from hazard unit

//Branch unit CU signls
    output wire [2:0] bu_op ,  // Output to Branch Unit

//ALU CU signals
    output wire  SE2 ,       //"0-> R[rb] , 1-> 1"
    output wire [1:0] SE3 , //"0-> ALU_res , 1-> R[ra] , 2-> R[rb]"
    output wire [3:0] ALU_CONTROL ,

//CCR CU signals
    output wire Z_Flag_en ,
    output wire N_Flag_en , 
    output wire C_Flag_en ,
    output wire V_Flag_en ,

//Reg file Decode signals
    output wire SD1 ,              // MUX 1: Write Address Selector (0=IR[ra], 1=3/SP)
    output wire SD2 ,             // MUX 2: Read A Selector (0= Immediate Value (Imm), 1=R[ra])
    output wire [1:0] SD3 ,      // MUX 3: Read B Selector (0=R[rb], 1=PC+1, 2=IR)

//Mem CU signals
    output wire Wm ,              //write memory control
    output wire SM2 ,            //memory mux2 selection (0->ALU res,1-> D_data memory port)

//Reg file Write Back signals 
    // RF write address/data selects
    output wire write_en,
    output wire sw1,         // 0 -> write ra, 1 -> write rb
    output wire sw2,        // 0 -> use wb_data, 1 -> force data_in

    // stack pointer controls (R3)
    output wire sp_inc,
    output wire sp_dec,

    // out port ld signal
    output wire ld_out,
    output wire HLT_en,

//PC CU signals 
    output wire         pc_en,
    output wire         pc_load,
    output wire         stall,
    output wire         sf1, // 0 always (inst data) , 1 Int (pc) //output to IR wire
    output wire [1:0]   pc_src,
    output wire [1:0]   addr_src,
    output wire         int_clr,

    output reg         Int_en,

    output wire [1:0] has_hazard ,
    output wire        flush_next

);

//wires 
wire [3:0] op_code ;
wire [1:0] ra ;


assign op_code = IR[7:4] ;
assign ra = IR[3:2] ; //or brx


//Branch Unit CU
    control_unit_branch_logic Branch_CU (
        .sf1(reg_sf1),
        .opcode(op_code),
        .ra(ra),
        .bu_op(bu_op)
    );  

//ALU CU
    CU_ALU ALU_CU (
        .sf1(reg_sf1),
        .op_code(op_code),
        .ra(ra),
        .SE2(SE2),
        .SE3(SE3),
        .ALU_CONTROL(ALU_CONTROL)
    );

//CCR CU 
    CU_CCR CCR_CU (
        .op_code(op_code),
        .ra(ra),
        .sf1(reg_sf1),
        .Z_Flag_en(Z_Flag_en),
        .N_Flag_en(N_Flag_en),
        .C_Flag_en(C_Flag_en),
        .V_Flag_en(V_Flag_en)
    );

//RegFile Decode CU
    RegFile_ControlUnit D_CU (
        .Opcode(op_code),
        .ra_brx(ra),
        .sf1(reg_sf1),
        .SD1(SD1),
        .SD2(SD2),
        .SD3(SD3)
    );

//Memory CU
    Memory_Stage_CU Mem_CU (
        .IR(IR),
        .sf1(reg_sf1),
        .Wm(Wm),
        .SM2(SM2)
    );

//RegFile Write Back CU 
    Write_Back_Stage_CU WB_CU(
        .opcode(op_code),
        .ra_wb(ra),
        .sf1(reg_sf1),
        .write_en(write_en),
        .sw1(sw1),
        .sw2(sw2),
        .sp_inc(sp_inc),
        .sp_dec(sp_dec),
        .ld_out(ld_out),
        .HLT_en(HLT_en)
    );

//PC CU
    Fetch_Stage_CU PC_CU(
        .clk(clk),
        .reset(rst),
        .intr(intr),
        .stall_in(stall_in),
        .opcode(op_code),
        .brx(ra),
        .branch_taken(branch_taken),
        .bypass_decode_done(bypass_decode_done), 
        .pc_en(pc_en),
        .pc_load(pc_load),
        .stall(stall),
        .sf1(sf1), 
        .pc_src(pc_src),
        .addr_src(addr_src),
        .int_clr(int_clr) ,
        .flush_next(flush_next)
    );
    hazard_CU u_hazard_CU(
        .opcode     (op_code     ),
        .ra         (ra          ),
        .sf1        (reg_sf1     ),
        .has_hazard (has_hazard  )
    );
    
    always @(posedge clk or negedge rst) begin
        if(!rst) Int_en = 1'b0;
        else if (sf1) Int_en = 1'b1; //interrupt
        else if (op_code == 4'd11 && ra == 2'd3 ) Int_en = 1'b0; //RTI
    end

endmodule