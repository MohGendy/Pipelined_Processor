###############################################################################
# AC701 Evaluation Board — Master XDC
# Target: XC7A200T-2FBG676C (Artix-7)
# Based on AC701 board master XDC template (UG952) and community repo. :contentReference[oaicite:1]{index=1}
###############################################################################

###############################################################################
# Differential System Clock (200 MHz)
###############################################################################

set_property PACKAGE_PIN K17 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name sys_clk -period 10.000 [get_ports clk]   
# 100 MHz example

# create_clock must match the incoming frequency (200 MHz -> 5 ns period)
# create_clock -name sys_clk -period 10.000 [get_ports clk]

###############################################################################
# User GPIO (Your Application Ports)
# Note: Replace <PIN_x> with actual AC701 I/O pins from board schematic.
###############################################################################

# Reset
# set_property PACKAGE_PIN <PIN_RST> [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# Interrupt
# set_property PACKAGE_PIN <PIN_INT> [get_ports int]
set_property IOSTANDARD LVCMOS33 [get_ports int]

# Halt
# set_property PACKAGE_PIN <PIN_HLT> [get_ports HLT]
set_property IOSTANDARD LVCMOS33 [get_ports HLT]

# 8-bit Input Bus
# set_property PACKAGE_PIN <PIN_IN0> [get_ports {In_port[0]}]
# set_property PACKAGE_PIN <PIN_IN1> [get_ports {In_port[1]}]
# …
# set_property PACKAGE_PIN <PIN_IN7> [get_ports {In_port[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports In_port[*]]

# 8-bit Output Bus
# set_property PACKAGE_PIN <PIN_OUT0> [get_ports {Out_port[0]}]
# set_property PACKAGE_PIN <PIN_OUT1> [get_ports {Out_port[1]}]
# …
# set_property PACKAGE_PIN <PIN_OUT7> [get_ports {Out_port[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports Out_port[*]]

###############################################################################
# Buttons & Switches (example on AC701)
# If you want to use board switches or buttons, uncomment & adjust:
###############################################################################
# set_property PACKAGE_PIN K17 [get_ports btn0]
# set_property IOSTANDARD LVCMOS33 [get_ports btn0]

# set_property PACKAGE_PIN M18 [get_ports sw0]
# set_property IOSTANDARD LVCMOS33 [get_ports sw0]
