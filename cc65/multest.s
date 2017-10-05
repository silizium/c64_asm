;multest
;20071004 by H.Behrens
;mail: pebbles@schattenlauf.de
		.setcpu "6502X"
		.MACPACK generic
;		.import c64
		.import BSOUT
		.import _tistart,_tistop,_tistprint,_tiprint
		.import multab,initmultab

.macro	chout char
		lda #char
		jsr BSOUT
.endmacro

		.segment "STARTUP"

.macro  basicstart nr
		.org $0801
;Basic Start
		.word *
		.org *-2
		.word @lline
		.ifnblank nr
		   .word nr		; Zeilennummer
		.else
		   .word 0
		.endif
		.byte $9e		; SYS
		.asciiz .sprintf ("%d", *+7)
@lline: .word 0
.endmacro



		basicstart 2007

PROD=$

_main: 		lda #$ff
		ldy #$ff
		jsr _tistart
		jsr multab
		jsr _tistprint
		
		rts
		
.include "mul32.s"