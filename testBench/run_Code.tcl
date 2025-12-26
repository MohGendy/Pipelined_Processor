vlib work
vlog -f sourcefile.txt
vsim -voptargs=+accs work.Run_Code_tb

# add wave form formating
do wave_run_Code.tcl

run -all