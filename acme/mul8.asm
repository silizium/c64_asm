;multipliziere 8 mal 8 bit
;
; md Multiplikant bleibt erhalten
; mr Multiplikator wird berschrieben
; das 16-Bit Produkt steht in:
; mr - Highbyte und
; a  - Lowbyte
!to 		"mul8.prg"
		*=$1000
md 		= $fd
mr		= $fe

mul		lda #0			;Setzen des Produkts
		ldx #8			;Zähler (8 Durchläufe)
.mulloop	asl 			;Produkt in A über
		rol mr			;mr nach links schieben
		bcc .mulnext		;höchstes Bit in mr=0
		clc			;Falls höchstes Bit in mr=1
		adc md			;md zum Teilprodukt addieren
		bcc .mulnext		;kein Ertrag
		inc mr			;Ertrag nach mr berücksichtigen
.mulnext	dex
		bne .mulloop		;weiter, falls Zähler noch nicht 0
		rts
