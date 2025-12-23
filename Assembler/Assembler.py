import sys
import os

# ---------------------------------------------------------
# 1. ISA Definition (Instruction Set)
# ---------------------------------------------------------
REGISTERS = {'R0': 0, 'R1': 1, 'R2': 2, 'R3': 3}

ISA = {
    # --- A-Format (ALU & Stack) ---
    'NOP':  {'opcode': 0,  'type': 'NO_OP',      'ra': 0, 'rb': 0},
    'MOV':  {'opcode': 1,  'type': 'R_R'},       
    'ADD':  {'opcode': 2,  'type': 'R_R'},
    'SUB':  {'opcode': 3,  'type': 'R_R'},
    'AND':  {'opcode': 4,  'type': 'R_R'},
    'OR':   {'opcode': 5,  'type': 'R_R'},
    
    'RLC':  {'opcode': 6,  'type': 'R_FIXED_RA', 'ra': 0}, 
    'RRC':  {'opcode': 6,  'type': 'R_FIXED_RA', 'ra': 1}, 
    'SETC': {'opcode': 6,  'type': 'NO_OP',      'ra': 2, 'rb': 0},
    'CLRC': {'opcode': 6,  'type': 'NO_OP',      'ra': 3, 'rb': 0},
    
    'PUSH': {'opcode': 7,  'type': 'R_FIXED_RA', 'ra': 0}, 
    'POP':  {'opcode': 7,  'type': 'R_FIXED_RA', 'ra': 1}, 
    'OUT':  {'opcode': 7,  'type': 'R_FIXED_RA', 'ra': 2}, 
    'IN':   {'opcode': 7,  'type': 'R_FIXED_RA', 'ra': 3}, 
    
    'NOT':  {'opcode': 8,  'type': 'R_FIXED_RA', 'ra': 0},
    'NEG':  {'opcode': 8,  'type': 'R_FIXED_RA', 'ra': 1},
    'INC':  {'opcode': 8,  'type': 'R_FIXED_RA', 'ra': 2},
    'DEC':  {'opcode': 8,  'type': 'R_FIXED_RA', 'ra': 3},
    
    # --- B-Format (Branching) ---
    'JZ':   {'opcode': 9,  'type': 'R_FIXED_RA', 'ra': 0}, 
    'JN':   {'opcode': 9,  'type': 'R_FIXED_RA', 'ra': 1}, 
    'JC':   {'opcode': 9,  'type': 'R_FIXED_RA', 'ra': 2}, 
    'JV':   {'opcode': 9,  'type': 'R_FIXED_RA', 'ra': 3}, 
    'LOOP': {'opcode': 10, 'type': 'R_R'},       
    
    'JMP':  {'opcode': 11, 'type': 'R_FIXED_RA', 'ra': 0}, 
    'CALL': {'opcode': 11, 'type': 'R_FIXED_RA', 'ra': 1}, 
    'RET':  {'opcode': 11, 'type': 'NO_OP',      'ra': 2, 'rb': 0},
    'RTI':  {'opcode': 11, 'type': 'NO_OP',      'ra': 3, 'rb': 0},
    
    # --- L-Format (Load/Store) ---
    'LDM':  {'opcode': 12, 'type': 'R_IMM',      'ra': 0}, 
    'LDD':  {'opcode': 12, 'type': 'R_IMM',      'ra': 1}, 
    'STD':  {'opcode': 12, 'type': 'R_IMM',      'ra': 2}, 
    'LDI':  {'opcode': 13, 'type': 'R_R'}, 
    'STI':  {'opcode': 14, 'type': 'R_R'}, 
}

# ---------------------------------------------------------
# 2. Helper Functions
# ---------------------------------------------------------
def parse_register(reg_str):
    reg_str = reg_str.upper().strip().replace(',', '')
    if reg_str in REGISTERS:
        return REGISTERS[reg_str]
    else:
        raise ValueError(f"Unknown register: {reg_str}")

def parse_immediate(imm_str):
    imm_str = imm_str.strip().replace(',', '')
    try:
        if imm_str.startswith('0x') or imm_str.startswith('0X'):
            return int(imm_str, 16)
        elif imm_str.startswith('0b'):
            return int(imm_str, 2)
        else:
            return int(imm_str)
    except ValueError:
        raise ValueError(f"Invalid immediate value: {imm_str}")

def assemble_line(line):
    line = line.split(';')[0].split('//')[0].strip()
    if not line: return []

    parts = line.split()
    mnemonic = parts[0].upper()
    
    if mnemonic not in ISA:
        raise ValueError(f"Unknown Instruction: {mnemonic}")
        
    instr_def = ISA[mnemonic]
    opcode = instr_def['opcode']
    instr_type = instr_def['type']
    
    ra = 0
    rb = 0
    imm = None
    
    try:
        if instr_type == 'NO_OP':
            ra = instr_def['ra']; rb = instr_def['rb']
        elif instr_type == 'R_FIXED_RA':
            ra = instr_def['ra']
            if len(parts) < 2: raise ValueError("Missing register")
            rb = parse_register(parts[1])
        elif instr_type == 'R_R':
            if len(parts) < 3: raise ValueError("Missing registers")
            ra = parse_register(parts[1])
            rb = parse_register(parts[2])
        elif instr_type == 'R_IMM':
            ra = instr_def['ra']
            rb = parse_register(parts[1])
            imm = parse_immediate(parts[2])
    except Exception as e:
        raise ValueError(f"Error parsing '{line}': {str(e)}")

    byte1 = (opcode << 4) | (ra << 2) | rb
    hex_codes = [f"{byte1:02X}"]
    if imm is not None:
        hex_codes.append(f"{imm & 0xFF:02X}")
        
    return hex_codes

# ---------------------------------------------------------
# 3. Main Execution
# ---------------------------------------------------------
def main():
    input_file = 'code.asm'    
    output_file = 'memory.hex'

    if not os.path.exists(input_file):
        print(f"ERROR: File '{input_file}' not found inside the folder.")
        print("Please create 'code.asm' and put your code in it.")
        return

    print(f"Reading from: {input_file}")
    
    with open(input_file, 'r') as f:
        lines = f.readlines()

    compiled_hex = []
    print("-" * 30)
    print(f"{'ADDR':<5} {'INSTRUCTION':<20} {'HEX'}")
    print("-" * 30)

    address = 0
    try:
        for line in lines:
            line = line.strip()
            if not line or line.startswith(';') or line.startswith('//'): continue
                
            hex_bytes = assemble_line(line)
            
            # Print cleanly to terminal
            hex_str = ' '.join(hex_bytes)
            print(f"{address:02X}    {line:<20} {hex_str}")
            
            compiled_hex.extend(hex_bytes)
            address += len(hex_bytes)
            
        # Write to file
        with open(output_file, 'w') as f:
            for h in compiled_hex:
                f.write(h + '\n')
                
        print("-" * 30)
        print(f"Success! Hex saved to '{output_file}'")
        
    except ValueError as e:
        print(f"\nSTOPPED: {e}")

if __name__ == "__main__":
    main()
