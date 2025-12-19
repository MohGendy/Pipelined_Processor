vlib work
vlog pc_reg.v 
vlog pc_in.v
vlog PC_CU.v
vlog mem_addr_mux.v
vlog pc_if_tb.v 
vsim -voptargs=+acc work.tb_pc_system
add wave *
run -all
#quit -sim
