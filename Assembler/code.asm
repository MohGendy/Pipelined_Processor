// ; code for test , edit this file and add your own code
LDM R1, 3     
LDM R2, 0       
LDM R0, 0x08   
NOP             
NOP             
ADD R2, R1      
LOOP R1, R0     
OUT R2  
