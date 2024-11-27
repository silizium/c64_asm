;2017 Hanno Behrens  
	.setcpu "6502X"
	.macpack generic
	.import SETLFS,SETNAM,OPEN,CLOSE,ERROR,GET
	.import BASIN,BSOUT,CHKIN,CKOUT,CLRCH,READST
	.macpack basicstart


	SCREEN	=$0400
	ST	=$90
	k_scrout	=$e716

	.segment "CODE"
	basicrem 2024		
.proc dumpchar
Start:
		ldy #$ff
		iny
		dec store+1
loop:		tya
store: 		sta SCREEN+1,y
		iny
		bne loop
		inc store+1
		rts
.endproc
	basicremend
