LDM R0, 0x0C    
    LDM R1, 0x2D    ; Compare with 45
    LDM R2, 0x14
    SUB R1, R0      ; R1 - R0
    JN  R2          ; If negative, R0 is bigger
    LDM R0, 0x2D    ; Otherwise, R0 = 45
;0x20:
    LDM R1, 0x17    ; Compare with 23
    LDM R2, 0x1E
    SUB R1, R0
    JN  R2
    LDM R0, 0x17
;0x30:
    LDM R1, 0x43    ; Compare with 67
    LDM R2, 0x28
    SUB R1, R0
    JN  R2
    LDM R0, 0x43
;0x40:
    LDM R1, 0x22    ; Compare with 34
    LDM R2, 0x32
    SUB R1, R0
    JN  R2
    LDM R0, 0x22
;0x50:
    OUT R0          ; Output maximum (67 = 0x43)