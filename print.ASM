; xa -O PETSCII -o print print.ASM
	putc = $ffd2

	*= $0801
	.text
;Header generieren
	.word *
	*= *-2
	.word endline		;Pointer to next line
	.word 2016		;line number
	.byt $9e		;Basic "SYS" token
	.asc "2061",0
endline	.word 0
;End Header

start	jsr print
	.asc "hello world!",13,0
	rts
;------------------------------

print:	pla		
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
.end
