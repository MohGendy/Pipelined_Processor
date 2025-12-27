vlib work
vlog -f sourcefile.txt
vsim -voptargs=+accs work.FIb_tb

# add wave form formating
do wave_fib.tcl

run -all