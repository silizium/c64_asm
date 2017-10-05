;hexout gibt den akku als hex aus
.export hexout
.proc	hexout
	print=$ffd2
		pha
		lsr a
		lsr a
		lsr a
		lsr a
		tax
		lda hexnum,x
		jsr print
		pla
		and #$0f
		tax
		lda hexnum,x
		jsr print
		rts
hexnum:		.byte "0123456789abcdef"
.endproc
