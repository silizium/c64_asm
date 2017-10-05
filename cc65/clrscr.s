;©2007 Hanno Behrens (pebbles@schattenlauf.de) 
	.setcpu "6502X"
	.macpack generic
	.import SETLFS,SETNAM,OPEN,CLOSE,ERROR,GET
	.import BASIN,BSOUT,CHKIN,CKOUT,CLRCH,READST

	.segment "STARTUP"

	SCREEN=$0400
	ST=$90
	k_scrout=$e716

	.org $1000
		.word *
		.org *-2
		
.proc clrscr
		lda #$20
		ldy #1
loop:		jsr _tistart
		sta SCREEN+000-1,y
		sta SCREEN+250-1,y
		sta SCREEN+500-1,y
		sta SCREEN+750-1,y
		dey
		bne loop
		jsr _tistprint
		
		rts
.endproc

.include "timer.s"