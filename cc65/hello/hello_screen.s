	.setcpu "6502X"
	.macpack generic
	.macpack cbm
	.import BSOUT
	screen=$0400
	.org $0801

.macro  basicstart nr
		.word :+
		.ifnblank nr
		   .word nr		; Zeilennummer
		.else
		   .word 0
		.endif
		.byte $9e			; SYS
		.asciiz .sprintf ("%d", *+7)
:		.word 0
.endmacro
	.segment "CODE"

	basicstart 2018

	ldy #0
loop:	lda text,y
	beq quit
	sta screen,y
	iny
	bne loop
quit:	rts

	.segment "RODATA"

text:	scrcode "hello world"
	.byte 0

