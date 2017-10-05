	!to "test.prg"
	*= $c000
START	LDY #0
L1	TYA
	STA $0400,Y
	INY
	BNE L1
	RTS
.END
