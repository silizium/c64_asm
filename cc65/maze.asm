; cl65 -t c64 -o print print.s -C crypto/c64-asm.cfg
; Example CALL BY VALUE RETURN

	.setcpu "6502X"
	.macpack generic
	.macpack cbm
	.import c64	
	.import BSOUT
	.include "c64.inc"	;FREKZP=$fb
	.macpack basicstart

;print for by value return
.macro	println text
	jsr printbvr
	.asciiz .sprintf("%s%c",text,13)
.endmacro

	.segment "CODE"

	basicstart 2022

_main:
	lda #$ff
	sta $d40f
	lda #$80
	sta $d412			; noise
	ldx #0
@loop:	ror $d41b			; get osc3 output
	txa 
	adc #205
	;rol a			; char 205/206
	jsr BSOUT
	bcc @loop

;	.segment "BSS"
;heap:	.byte 0
.end

