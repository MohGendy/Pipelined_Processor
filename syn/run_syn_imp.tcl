# ===============================
# 1. RTL Sources
# ===============================
set source_files {
    ALU/ALU.v
    ALU/CCR.v
    ALU/Mux.v
    CU/CU_ALU.v
    CU/CU_CCR.v
    CU/CU_TOP.v
    CU/D_CU.v
    CU/hazard_CU.v
    CU/Mem_CU.v
    CU/PC_CU.v
    CU/WB_control.v
    CU/BranchUnit_CU.v
    Instruction_reg/Instruction_reg.v
    Latches/D_Ex.v
    Latches/Ex_M.v
    Latches/M_Wb.v
    Memory/Memory.v
    PC/2to1_mux.v
    PC/4to1_mux.v
    PC/adder.v
    PC/IF_Stage.v
    PC/mem_addr_mux.v
    PC/pc_in.v
    PC/pc_reg.v
    Pipeline/Branch_Unit.v
    Pipeline/bypass_jmp.v
    Pipeline/hazard_forwarding_unit.v
    Pipeline/Virtual_SP.v
    Ports/ports_interrupt.v
    Register_File/RegFile.v
    TOP/top.v
}

# Add RTL files
add_files $source_files

# ===============================
# 2. Top Module
# ===============================
set_property top top [current_fileset]
update_compile_order -fileset sources_1

# ===============================
# 3. Constraints
# ===============================
add_files -fileset constrs_1 ./constraints.xdc

# ===============================
# 4. Run Synthesis
# ===============================
launch_runs synth_1 -jobs 4
wait_on_run synth_1
open_run synth_1

# Reports
report_utilization -file utilization_report.txt
report_timing_summary \
    -delay_type min_max \
    -report_unconstrained \
    -max_paths 10 \
    -file timing_report.txt

# ===============================
# 5. Run Implementation
# ===============================
launch_runs impl_1 -jobs 4
wait_on_run impl_1
open_run impl_1

# ===============================
# 6. Implementation Reports
# ===============================
report_utilization -file impl_utilization.txt
report_timing_summary \
    -delay_type min_max \
    -report_unconstrained \
    -max_paths 10 \
    -file impl_timing.txt

report_clock_utilization -file clock_utilization.txt
report_power -file power_report.txt

puts "--- Synthesis + Implementation Completed Successfully ---"