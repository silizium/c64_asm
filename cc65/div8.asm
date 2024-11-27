;normal binary division
ASL $FD
LDA #$00
ROL

LDX #$08
.loop1
CMP $FC
BCC *+4
SBC $FC
ROL $FD
ROL
DEX
BNE .loop1

LDX #$08
.loop2
CMP $FC
BCC *+4
SBC $FC
ROL $FE
ASL
DEX
BNE .loop2