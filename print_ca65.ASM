; xa -O PETSCII -o print print.ASM
	.setcpu "6502"
	putc = $ffd2
	uintout	= $bdcd		;Basic print positive int (a/x)

	sp = $0100

	.macro print Arg 
	jsr _print
	.byt Arg
	.endmacro

	.macro putchar Arg
	lda #Arg
	jsr putc
	.endmacro

	.code
	.org $0801
;generate header
	.word *
	.org *-2
	.word endline		;Pointer to next line
	.word 2016		;line number
	.byt $9e		;Basic "SYS" token
	.byt "2061",0
endline:.word 0
;End Header

start:	print {"HELLO WORLD!",13,0}
	ldx #10
loop:	txa
	pha
	lda #0
	jsr uintout
	putchar 13
	pla
	tax
	dex
	bne loop
	print {"END LOOP",13,0}
	rts
;------------------------------

_print:	pla						;lo pointer of return
	sta pmod+1					;is pointer to string/self modifying
	pla						;hi pointer of return
	sta pmod+2					;is high pointer of string
pmod:	lda $0100					;“0100” gets modified
	beq pexit					;end printing if NULL terminated
	jsr putc					;system “putc”, prints accu
	inc pmod+1					;inc string pointer
	bne pmod
	inc pmod+2					;if high has to be increased
	bne pmod					;should always be not equal
pexit:	lda pmod+2					;put new return address 
	pha							;on stack
	lda pmod+1
	pha
	rts		
.end
