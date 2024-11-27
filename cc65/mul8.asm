;multipliziere 8 mal 8 bit
;
; md Multiplikant bleibt erhalten
; mr Multiplikator wird überschrieben
; das 16-Bit Produkt steht in:
; MR - Highbyte und
; a  - Lowbyte

MD 		= $fd
MR		= $fe

.proc mul: near
		lda #0			;Setzen des Produkts
		ldx #8			;Zähler (8 Durchläufe)
@mulloop:		asl 			;Produkt in A über
		rol MR			;mr nach links schieben
		bcc @mulnext		;höchstes Bit in mr=0
		clc			;Falls höchstes Bit in mr=1
		adc MD			;md zum Teilprodukt addieren
		bcc @mulnext		;kein Ertrag
		inc MR			;Ertrag nach mr berücksichtigen
@mulnext:	dex
		bne @mulloop		;weiter, falls Zähler noch nicht 0
		rts
.endproc


