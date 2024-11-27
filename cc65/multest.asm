;multest
;20071004 by H.Behrens
;mail: pebbles@schattenlauf.de
		.setcpu "6502X"
		.MACPACK generic
;		.import c64
		.import BSOUT
		.import _tistart,_tistop,_tistprint,_tiprint
;		.import multab,initmultab

.macro	chout char
		lda #char
		jsr BSOUT
.endmacro

;		.segment "STARTUP"

		.include "basicstart.inc"

		.code
		basicstart 2007

_main:		jsr initmultab
		lda #$ff
		ldy #$ff
		jsr _tistart
		jsr multab
		jsr _tistprint
		
		rts
		
.include "multab.asm"
