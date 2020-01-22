; cl65 -t c64 -o print print.s -C crypto/c64-asm.cfg
	putc = $ffd2

	.setcpu "6502X"
	.macpack generic
	.macpack cbm
	.import c64
	.import BSOUT

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
	sta pmod+1	;self modifying code
	pla
	sta pmod+2
pmod:	lda $0100
	beq pexit
	jsr putc
	inc pmod+1
	bne pmod
	inc pmod+2
	bne pmod
pexit:
	lda pmod+2
	pha
	lda pmod+1
	pha
	rts

	.segment "BSS"
heap:	.byte 0
.end

