vlib work
vlog -f sourcefile.txt
vsim -voptargs=+accs work.Top_tb

# add wave form formating
# add wave * 
# add wave sim:/Top_tb/uut/* 
# add wave sim:/Top_tb/uut/u_Memory/Mem 
do wave.tcl

run -all