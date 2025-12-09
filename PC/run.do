vlib work
vlog pc_new.v pc_new_tb.v 
vsim -voptargs=+acc work.pc_new_tb
add wave *
run -all
#quit -sim
