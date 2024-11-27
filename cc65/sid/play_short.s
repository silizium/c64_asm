;2024 Hanno Behrens  
        .setcpu "6502X"
        .macpack generic
        .import SETLFS,SETNAM,OPEN,CLOSE,ERROR,GET
        .import BASIN,BSOUT,CHKIN,CKOUT,CLRCH,READST

        SCREEN=$0400
        ST=$90
        k_scrout=$e716

        .org $3000

        .segment "CODE"
.proc playsid
Start:
	SEI
	LDA #$00
	JSR $1000 ;Tune Init
l1:	LDA $D012
	CMP #$72
	BNE l1
	INC $D020
l2:	JSR $1003 ;Tune Play
	DEC $D020
	LDA $DC01
	CMP #$EF
	BEQ l2
	BNE l1
.endproc
