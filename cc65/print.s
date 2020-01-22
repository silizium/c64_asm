; cl65 -t c64 -o print print.s -C crypto/c64-asm.cfg
; Example CALL BY VALUE RETURN

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
;print for by value return
.macro	println text
	jsr printbvr
	.asciiz .sprintf("%s%c",text,13)
.endmacro

	.segment "CODE"

	basicstart 2020

_main:	println "hello world!"
	rts
;------------------------------
; print by value return
.proc printbvr
	pla		
	sta FREKZP		;sta pmod+1	;version with self modifying code
	pla
	sta FREKZP+1		;sta pmod+2
	ldy #0
@pmod:	
	lda (FREKZP),y		;lda $0100
	beq @pexit
	jsr BSOUT
	iny			;inc pmod+1 ;bne pmod ;inc pmod+2 ;bne pmod
	bne @pmod
@pexit:
	sec
	tya
	adc FREKZP
	sta FREKZP
	lda #0
	adc FREKZP+1
	sta FREKZP+1
	jmp (FREKZP)		;lda pmod+2 ;pha ;lda pmod+1 ;pha ;rts
.endproc

;	.segment "BSS"
;heap:	.byte 0
.end

