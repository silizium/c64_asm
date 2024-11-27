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

	basicrem 2024

_main:
	ldy #1
	lda #$ff
	sta $d40e,y
	lda #$80
	sta $d411,y		; noise
	ldx #$ff
	inx
@loop:	ror $d41b			; get osc3 output
	txa 
	adc #205
	jsr BSOUT
	ror $d41b			; get osc3 output
	txa 
	adc #205
	jsr BSOUT
	ror $d41b			; get osc3 output
	txa 
	adc #205
	jsr BSOUT
	ror $d41b			; get osc3 output
	txa 
	adc #205
	jsr BSOUT
	ror $d41b			; get osc3 output
	txa 
	adc #205
	jsr BSOUT
	bne @loop

	basicremend
;	.segment "BSS"
;heap:	.byte 0
.end

