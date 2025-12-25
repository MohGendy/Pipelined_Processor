vlib work
vlog -f sourcefile.txt
vsim -voptargs=+accs work.get_max_tb

# add wave form formating
do wave_get_max.tcl

run -all