.code
.proc Main
		ldx #$ff
		
inner:	lda incins+2
		cmp #$07
		bne incins
		
		lda incins+1
		cmp #$e8
		bne incins
		
		dex
		beq end
		lda #$04
		sta incins+2
		lda #$00
		sta incins+1
		
incins:	inc $0400
		
		inc incins+1
		bne inner
		inc incins+2
		jmp inner
		
end:	rts
.endproc