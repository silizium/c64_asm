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

start	ldx #%10110111
;-----------------------------state 1
state1	txa
	lsr
	tax
	bcc lf
;-----------------------------state 2
	ldy #msge-msg
prloop	lda msg-1,y
	jsr print
	dey
	bne prloop
endmsg	beq state1
;-----------------------------state 3
lf	beq return
	lda #$0d
	jsr print
	bne state1
return	rts

msg:	.asc "!elims"
msge:

.end
