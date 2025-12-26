vlib work
vlog -f sourcefile.txt
vsim -voptargs=+accs work.push_pop_tb

# add wave form formating
do wave_push_pop_tb.tcl

run -all