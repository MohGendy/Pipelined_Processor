# Pipelined Processor (University Project)

This repository contains a simple pipelined processor implementation (RTL Verilog), its testbenches, an assembler utility, and scripts to run simulations and view waveforms. It was developed as a university microarchitecture project and includes modules for the ALU, control unit, register file, memory, pipeline stages, and a small assembler to generate program memory images.

**Quick highlights:**
- Language: Verilog (RTL)
- Testbenches: Multiple testbenches in `TOP/`
- Assembler: Python script in `Assembler/` that produces `memory.hex`
- Simulation scripts: Several TCL scripts (`run*.tcl`, `wave*.tcl`) to automate ModelSim/Questa/Vivado simulation and waveform capture

**Note:** This README provides a practical guide to the repository layout, how to run simulations, and how to use the assembler. Adjust simulator commands to your local tools (ModelSim, Questa, Vivado, etc.).

**Contents**

- `TOP/` - Top-level module and testbenches (e.g. `top.v`, `top_tb.v`, `Run_Code_tb.v`, `Fibonacci_tb.v`, `get_max_tb.v`, etc.). The primary integration happens here.
- `ALU/`, `CU/`, `PC/`, `Memory/`, `Latches/`, `Pipeline/`, `Instruction_reg/`, `Register File/` - RTL modules grouped by function (ALU, control unit, program counter and muxes, memory, pipeline latches, forwarding/hazard logic, instruction register, and register file).
- `Assembler/` - Python assembler (`Assembler.py`) and example assembly programs (e.g. `get_max.asm`, `code.asm`) and generated `memory.hex`.
- `syn/` - Synthesis project files and a Vivado XPR (`pipeline_syn.xpr`) and constraints.
- `testBench/` - TCL simulation scripts (e.g. `run_*.tcl`, `wave_*.tcl`) for automated runs and waveform capture.

Getting started
---------------

Prerequisites:

- A Verilog simulator (ModelSim/Questa, Vivado Simulator, or other).
- Python 3 for running the assembler (if you need to regenerate `memory.hex`).

Typical workflow:

1. Assemble an assembly file (optional):

```bash
python Assembler/Assembler.py
```

2. Run simulation using the provided TCL scripts. Examples (ModelSim/Questa):

```tcl
# In ModelSim/Questa command prompt or via vsim -do
do testBench/run_Code.tcl
```

There are also dedicated scripts for particular tests and waveform setups (located in `testBench/`), for example:

 - `testBench/run_fib.tcl`, `testBench/run_get_max.tcl`, `testBench/run_interrupt_tb.tcl` — run those testbenches.
 - `testBench/wave.tcl`, `testBench/wave_get_max.tcl`, `testBench/wave_fib.tcl` — configure waveform views and dump files.

Top-level flow and tests
-----------------------

- The `top` module (in `TOP/top.v`) integrates the pipeline and exposes `clk`, `rst`, `In_port`, `Out_port`, and an `HLT` signal.
- Testbenches in `TOP/` exercise the processor: `Fibonacci_tb.v`, `get_max_tb.v`, `interrupt_tb.v`, `push_pop_tb.v`, `Run_Code_tb.v`, `SP_test_tb.v`.
- `Run_Code_tb.v` is a harness that loads `Assembler/memory.hex`, initializes register file contents, applies reset, runs until `HLT`, and prints a pass/fail summary.

Assembler
---------

- The assembler is a small Python utility in `Assembler/Assembler.py`. It converts human-readable assembly programs into a `memory.hex` file suitable for `$readmemh` in Verilog memory initialisation.
- Example assembly source files are in `Assembler/` (e.g. `get_max.asm`, `code.asm`, `feb.asm`). The assembler usage is shown above in "Getting started".

Directory reference (short)
--------------------------

- `ALU/` — ALU implementation and testbench.
- `CU/` — Control unit modules (branch unit, hazard control, memory control, etc.).
- `Memory/` — Memory RTL and `Memory_tb.v` testbench.
- `PC/` — Program counter logic and muxes.
- `Latches/` — Pipeline latch modules between stages.
- `Pipeline/` — Pipeline-level modules (forwarding, branch unit, virtual stack pointer logic).
- `Register File/` — Register file RTL and tests.
- `testBench/` — TCL simulation scripts and waveform setup.
- `syn/` — Synthesis (Vivado) project and generated files.

Development notes & tips
-----------------------

- When changing instruction encodings or control signals, update the assembler and tests to match.
- Use the provided `wave*.tcl` scripts to consistently view important signals (PC, instruction bus, pipeline registers, ALU outputs, flags, and HLT).
- If you see mismatches between expected register/memory contents and simulation, run the relevant individual testbench (e.g., `ALU/ALU_TB.v` or `Memory/Memory_tb.v`) to isolate the issue.

Authors
-------

- Moh Gendy
- Yasmeem Haitham
- Haneen Rabea
- Haneen Fouad
- Mohammed Nagi
- Mustafa Gamal



