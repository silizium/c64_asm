;Timerroutinen für den C64
;unter GPL (C) 2005 Hanno Behrens
;Assembleriert unter ACME Cross-Assembler
;zählt die Taktzyklen zwischen start und stopp
;mit bis zu 4 Byte (~70 Minuten bis Überlauf)
;email pebbles@schattenlauf.de


!cpu	6502
!to	"timer.prg"
!src	<C64/cia2.a>

b_ulongtofac = $bc4f
b_factostring = $bddd
b_stringpointer = $b487
b_printstring = $ab21

zp_fac_exp = $61
zp_fac_man = $62
timerval=zp_fac_man


	*=$c000 

tistart	jmp starttimer		;Einsprung timerstart
tistop	jmp stoptimer		;Einsprung timerstopp
tiprint jmp printtimer		;Einsprung timerprint
tistprint jmp stopprinttimer	;Einsprung stop+print
	
starttimer:
	lda #%11000000		;beide Timer stoppen
	sta cia2_cra
	lda #%01000000
	sta cia2_crb
	lda #$ff		;init Timer A+B auf $ffff
	sta cia2_ta_lo
	sta cia2_ta_hi
	sta cia2_tb_lo
	sta cia2_tb_hi
	lda #%01000001
	sta cia2_crb
	lda #%11000001
	sta cia2_cra
	sei
	rts
	
stoptimer:
	lda #%11000000
	sta cia2_cra
	lda #%01000000
	sta cia2_crb
	cli
	ldy #3
	ldx #0
stop1	lda cia2_ta_lo,x
	sta timerval,y
	inx
	dey
	bpl stop1
	lda #24			;24 Zyklen dauert der Aufruf Start/Stop
	jsr subzyklen		;vom Timerwert subtrahieren (addieren auf Negativ)
	rts			;Timer abwärts zählt ($ffffffe8-timer)

printtimer:
	ldy #3			;Timerval negieren
	sec
pt_l1:	lda timerval,y		;alle Werte
	eor #$ff		;negieren
	adc #0			;eins dazuzählen
	sta timerval,y
	dey
	bpl pt_l1
	sec			;4 Byte Integer to FAC
	lda #0
	ldx #$a0
	jsr b_ulongtofac	;konvertiere timerval zu Fließkomma
	jsr b_factostring	;konvertiere Fließkomma zu String (bei $100)
	jsr b_stringpointer	;setze die Stringpointer
	jsr b_printstring	;drucke den String
	rts

stopprinttimer:			;Variante stopp+print sorgt für Funktionieren auch von Basic aus
	jsr stoptimer		;Stoppt den Timer
	lda #6
	jsr subzyklen
	jsr printtimer		;druckt das Ergebnis auf den Bildschirm
	rts			;von Basic aus (per sys) variieren die Zyklen, da der Interrupt zwischenfunkt 

subzyklen:			;subtrahiert die Zyklen, die zur Messung nötig waren, Argument im Akku 
	clc
	adc timerval+3
	sta timerval+3
	ldy #2
sub1:	lda timerval,y
	adc #$00
	sta timerval,y
	dey
	bpl sub1
	rts	
;Testroutinen für das Funktionieren des Timers 
;nicht notwendig
	
test1:
	jsr tistart		; Testet den Nullfall, startet den Timer
				; Keine Befehle 
	jsr tistop		; stoppt den Timer
	jsr tiprint		; solllte "0" Ausgaben, weil 0 Zyklen verbraucht wurden
	rts

test2:
	jsr tistart		; Testet leichten Lastfall, startet Timer
	nop			; NOP=2 Zyklen
	nop
	jsr tistprint		; Variante Stopp+gleichzeitiger Ausdruck, sollte "4" Zyklen ergeben
	rts
