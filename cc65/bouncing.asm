	.setcpu "6502X"
	.macpack generic
	.import SETLFS,SETNAM,OPEN,CLOSE,ERROR,GET
	.import BASIN,BSOUT,CHKIN,CKOUT,CLRCH,READST


	SCREEN=$0400
	ST=$90
	k_scrout=$e716

	pt1=$fb	
	pt2=$fd
	tmppptr=$4b		
	fac1=$61
	fac2=$69
	fac3=$57		
	fac4=$5c	
	stack=$100
		
	accu=pt1
	arg=accu+2

	.org $1000
		
	.segment "CODE"
.proc bouncing
Start:
		lda #$00
		sta pt1
		lda #$04
		sta pt1+1
		ldy #0
		lda #81
loop:		sta SCREEN,y
		iny
		bne loop
		rts
.endproc

