; cl65 -t c64 -o print print.s -C crypto/c64-asm.cfg

	.setcpu "6502X"
	.macpack generic
	.macpack cbm
	.import c64	
	.import BSOUT
	.include "c64.inc"	;FREKZP=$fb


.macro  basicstart nr
	.org $0801
;Basic Start
;	.word *
;	.org *-2
	.word @lline
	.ifnblank nr
		.word nr	; Zeilennummer
	.else
		.word 0
	.endif
	.byte $9e		; SYS
	.asciiz .sprintf ("%d", *+7)
@lline:	.word 0
.endmacro

.macro	println text
	jsr printbvr
	.asciiz .sprintf("%s%c",text,13)
.endmacro

	.segment "CODE"

	basicstart 2020

_main:	println "hello world!"
	rts
;------------------------------

printbvr:	pla		
				;sta pmod+1	;self modifying code
	sta FREKZP
	pla
				;sta pmod+2
	sta FREKZP+1
	ldy #0
pmod:	
				;lda $0100
	lda (FREKZP),y
	beq pexit
	jsr BSOUT
	iny
	bne pmod
				;inc pmod+1
				;bne pmod
				;inc pmod+2
				;bne pmod
pexit:
	sec
	tya
	adc FREKZP
	sta FREKZP
	lda #0
	adc FREKZP+1
	sta FREKZP+1
	 
	jmp (FREKZP)

				;lda pmod+2
				;pha
				;lda pmod+1
				;pha
				;rts

;	.segment "BSS"
;heap:	.byte 0
.end

