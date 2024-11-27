	.include "../basicstart.mac"
	.macpack cbm

	basicstart 2024
 
Q        = 2
XPIXSHIFT = 4
TMP1     = 5
TEXTPTR  = 6
 
SCRLADR  = $0400
 
	JSR $E544
 
	SEI
TEXTRESTART:
	LDA #<TEXT
	STA TEXTPTR
	LDA #>TEXT
	STA TEXTPTR+1
 
LOOP:	INC $d012
	BNE LOOP
 
DESTSTART = *+1
	LDX #39;39
SRCSTART = *+1
	LDY #39;37
 
XPIXSHIFTADD:
	DEC XPIXSHIFT
 
	LDA XPIXSHIFT
	AND #7
	STA $D016
 
	CMP XPIXSHIFT
	STA XPIXSHIFT
	BEQ LOOP
 
	LDA SCRLADR,Y
	STA TMP1
	LDA SCRLADR-1,Y
	PHA
S:
	LDA TMP1
	STA SCRLADR-1,X
	PLA
	STA TMP1
	LDA SCRLADR-2,Y
	PHA
	DEY
	DEX
	BNE S
	PLA
GETNEWCHAR:
TEXTADR  = *+1
	LDA (TEXTPTR,X)
	BEQ TEXTRESTART
 
	INY
	BMI *+4
	LDX #$27
 
NOBEGIN: INC TEXTPTR
	BNE *+4
	INC TEXTPTR+1
 
	TAY
	BMI DIRCHANGE
 
	STA SCRLADR,X
	BPL LOOP
;---------------------------------------
DIRCHANGE: 
	LDA XPIXSHIFTADD
	EOR #$20
	STA XPIXSHIFTADD
 
	LDX DESTSTART
	LDY SRCSTART
	DEX
	INY
	STX SRCSTART
	STY DESTSTART
	BNE LOOP
;---------------------------------------
TEXT:	scrcode " this scroller can"
	scrcode " scroll in forward"
	scrcode " and backward direc"
	scrcode "tion!	      "
	scrcode "		  "
	scrcode "	"
	.byte $ff
	scrcode "won gnillorcs morf "
	scrcode "tfel ot thgir ... . "
	scrcode "		  "
	scrcode "		  "
	.byte $ff,0
