;Timerroutinen für den C64
;unter GPL (C) 2005 Hanno Behrens
;Assembleriert unter ACME Cross-Assembler
;zählt die Taktzyklen zwischen start und stopp
;mit bis zu 4 Byte (~70 Minuten bis Überlauf)
;email: pebbles@schattenlauf.de


.import c64
.include "c64io.inc"
.export _tistart,_tistop,_tiprint,_tistprint

b_ulongtofac = $bc4f
b_factostring = $bddd
;b_stringpointer = $b487
;b_printstring = $ab21
b_printstring = $ab1e

zp_fac_exp = $61
zp_fac_man = $62
timerval=zp_fac_man

_tistart:	jmp starttimer		;Einsprung timerstart
_tistop:	jmp stoptimer		;Einsprung timerstopp
_tiprint: 	jmp printtimer		;Einsprung timerprint
_tistprint: 	jmp stopprinttimer	;Einsprung stop+print
	
.proc starttimer
	php
	pha
	txa
	pha
	tya
	pha
	lda #%11000000		;beide Timer stoppen
	sta CIA2+CIA::CRA
	lda #%01000000
	sta CIA2+CIA::CRB
	lda #$ff		;init Timer A+B auf $ffff
	sta CIA2+CIA::TALO
	sta CIA2+CIA::TAHI
	sta CIA2+CIA::TBLO
	sta CIA2+CIA::TBHI
	lda #%01000001
	sta CIA2+CIA::CRB
	lda #%11000001
	sta CIA2+CIA::CRA
	pla
	tay
	pla
	tax
	pla
	plp
	sei
	rts
.endproc
	
.proc stoptimer
	php
	pha
	txa
	pha
	tya
	pha
	lda #%11000000
	sta CIA2+CIA::CRA
	lda #%01000000
	sta CIA2+CIA::CRB
	cli
	ldy #3
	ldx #0
stop1:	lda CIA2+CIA::TALO,x
	sta timerval,y
	inx
	dey
	bpl stop1
	lda #60			;24 Zyklen dauert der Aufruf Start/Stop
	jsr subzyklen		;vom Timerwert subtrahieren (addieren auf Negativ)
	pla
	tay
	pla
	tax
	pla
	plp
	rts			;Timer abwärts zählt ($ffffffe8-timer)
.endproc

.proc printtimer
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
;	jsr b_stringpointer	;setze die Stringpointer
	jsr b_printstring	;drucke den String
	rts
.endproc

.proc stopprinttimer		;Variante stopp+print sorgt für Funktionieren auch von Basic aus
	php
	pha
	txa
	pha
	tya
	pha
	jsr stoptimer		;Stoppt den Timer
	lda #22
	jsr subzyklen
	jsr printtimer		;druckt das Ergebnis auf den Bildschirm
	pla
	tay
	pla
	tax
	pla
	plp
	rts			;von Basic aus (per sys) variieren die Zyklen, da der Interrupt zwischenfunkt 
.endproc

.proc subzyklen			;subtrahiert die Zyklen, die zur Messung nötig waren, Argument im Akku 
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
.endproc
	
;Testroutinen für das Funktionieren des Timers 
;nicht notwendig
.proc test1
	jsr _tistart		; Testet den Nullfall, startet den Timer
				; Keine Befehle 
	jsr _tistop		; stoppt den Timer
	jsr _tiprint		; solllte "0" Ausgaben, weil 0 Zyklen verbraucht wurden
	rts
.endproc

.proc test2
	jsr _tistart		; Testet leichten Lastfall, startet Timer
	nop			; NOP=2 Zyklen
	nop
	jsr _tistprint		; Variante Stopp+gleichzeitiger Ausdruck, sollte "4" Zyklen ergeben
	rts
.endproc