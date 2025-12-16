vlib work
vlog Fetch_Unit.v 
vlog pc_if_tb.v 
vsim -voptargs=+acc work.Fetch_Unit_TB
add wave *
run -all
#quit -sim
