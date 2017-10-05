.struct CIA
	PRA .byte
	PRB .byte
	DDRA .byte
	DDRB .byte
	TALO .byte
	TAHI .byte
	TBLO .byte
	TBHI .byte
	TOD10THS .byte
	TODSEC .byte
	TODMIN .byte
	TODHR .byte
	SDR .byte
	ICR .byte
	CRA .byte
	CRB .byte
.endstruct

.struct Voice
	freq .word
	w .word
	ctrl .byte
	ad .byte
	sr .byte
.endstruct

.struct Sid
	v1 .tag Voice
	v2 .tag Voice
	v3 .tag Voice
	flt_freq .word				; Filter frequency 
	flt_ctrl .byte				; Filter control register 
	amp .byte					; Amplitude 
	ad1 .byte 					; A/D converter 1 
	ad2 .byte 					; A/D converter 2 
	noise .byte					; Noise generator 
	read3 .byte					; Value of voice 3 
.endstruct

CIA1=$dc00
CIA2=$dd00
SID=$d400
