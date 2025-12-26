vlib work
vlog -f sourcefile.txt
vsim -voptargs=+accs work.SP_test_tb

# add wave form formating
do wave_SP_test.tcl

run -all