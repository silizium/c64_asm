;2017 Hanno Behrens  
	.setcpu "6502X"
	.macpack generic
	.import SETLFS,SETNAM,OPEN,CLOSE,ERROR,GET
	.import BASIN,BSOUT,CHKIN,CKOUT,CLRCH,READST


	SCREEN=$0400
	ST=$90
	k_scrout=$e716

	.org $1000
		
	.segment "CODE"
.proc dumpchar
Start:
		ldy #0
loop:		tya
		sta SCREEN,y
		iny
		bne loop
		rts
.endproc

