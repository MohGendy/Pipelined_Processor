vlib work
vlog -f sourcefile.txt
vsim -voptargs=+accs work.Memory_tb

add wave *
add wave -color pink -radix hexadecimal sim:/Memory_tb/DUT/Mem

run -all