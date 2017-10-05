; xa -O PETSCII -o hello hello.asm
	print = $ffd2

	*= $0801
	.text
;Header generieren
	.word *
	*= *-2
	.word endline		;Zeiger auf nächste Zeile
	.word 2016		;Zeilennummer
	.byt $9e		; Basic SYS
	.asc "2061",0
endline	.word 0
;Ende Header

start	ldy #$00
l1	lda msg,Y
	beq l2
	jsr print
	iny
	bne l1
l2	rts

msg:	.asc "hello world!",13,0

.end
