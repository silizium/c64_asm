	.org  $c000
	ldy #0
@l:	tya
	sta $0400,y
	iny
	bne @l
	rts
	jmp @l
