!cpu 6502
!convtab pet
!to "basic.prg"
!sl "basicLabel.asm"
v_igone     =$0308  ; Vektor Basic-Befehl ausführen
v_ieval     =$030a  ; Vektor Basic-Token auswerten
s_synErr            =$af08  ; Syntax Error

;--------------------------------------------------------------------------------
; Ein paar Dinge zum einfachen Holen von Parametern
;--------------------------------------------------------------------------------
s_checkKlammerAuf   =$aefa
s_checkKlammerZu    =$aef7
s_checkKomma        =$aefd
s_getKommaByte      =$e200  ; Byte ins XReg
s_getByte           =$e203  ; Byte ins XReg
s_getWordKommaByte  =$b7eb  ; Word nach $14/$15, Komma, Byte nach X holen (wie Poke)
s_getNumerisch      =$ad8a  ; Irgendwas numerisches in den FAC

frmevl              =$ad9e  ; Ausdruck auswerten, kann also alles mögliche holen: Strings, Zahlen... 
; Zahlen finden sich im FAC, 
; Strings entweder in einem temporären Stringstapel oder noch in den Variablenverweisen.
; $0d gibt Auskunft über den geholten Wert
; für Strings (aus Variablen) ist anschliessend noch s_stringAufbereiten nötig, das tut aber auch bei direkten Strings nicht weh.
; Strings finden sich ab dem Pointer in $22/$23, die Länge im Akku. Und nach dem Aufbereiten auch bei Stringvariablen.
f_stringNum         =$0d    ; Ergebnis der Auswertung. Neg: String, Positiv: Numerisch
s_typTesten         =$ad90  ; I: $0d, Carry=1/0: Auf String/Numerisch prüfen.
; Braucht man meistens nicht, imho nur nach frmevl nützlich.
s_stringAufbereiten =$b6a3  ; frmevl gibt String-Variablen anders zurück. Daten zur Variablen aufbereiten. Scahdet auch bei normalen Strings nicht
                            ; $22/$23: Pointer auf den Text, Akku=Länge
;--------------------------------------------------------------------------------
; Ein bisschen nützliches für den FAC
;--------------------------------------------------------------------------------
s_facRunden     =$bc1b
s_facToInt      =$b1bf  ; Ins Integerformat nach $64/$65, also -32768 bis 32767
s_facToWord     =$b7f7  ; Ins Word-Format nach $14/$15, also 0 bis 65535
;--------------------------------------------------------------------------------
; Ein paar Dinge zur Rückgabe
;--------------------------------------------------------------------------------
s_returnByteY           =$b3a2  ; Yreg zurückgeben
s_returnByteAkku        =$bc3c  ; AKku zurückgeben (Nebenefekte??)
s_returnWord            =$b391  ; Y/Akku zurückgeben
s_returnString_Tmp      =$b487  ; Pointer A/Y als temporärern String zurückgeben. Nullbyte oder " ist Ende!!
                            	; Temporäre Strings haben ausserdem komische Nebeneffekte, Print und so kommen prima damit zurecht,
                            	; nur zum Speichern in Variablen muß man sie erst noch mit Leerstrings verknüpfen.
                            	; also aus Sicht des Basics nicht die beste Routine.
					        	; 1) oben Links A@ schreiben
					        	; 2) a$=<-z
					        	; 3) oben Links B@ schreiben
					        	; 4) Print a$ ergibt b !!
					        	; Ausserdem muß man darauf achten, daß auch wirklich ein @ oder ein " vorkommt
s_makeString            =$b47d  ; Akku=Länge, Platz im Stringspeicher besorgen, x/y bzw. $62/63: Adresse, Akku/$61: Länge
s_returnString          =$b4ca  ; Aus $61/$62/$63 wird der String richtig fertig gemacht (was auch immer da noch zu tun ist...)
;--------------------------------------------------------------------------------
*=$c000
        	; Vektor für Befehle umstellen
	        lda#<s_igone
    	    ldx#>s_igone
        	sta v_igone
	        stx v_igone+1
        
    	    ;Vektor für Funktionen umstellen.
        	lda#<s_ieval
	        ldx#>s_ieval
    	    sta v_ieval
        	stx v_ieval+1
	        rts
        
;--------------------------------------------------------------------------------
; Basic-Befehle erkennen und verarbeiten
;--------------------------------------------------------------------------------
s_igone
     	   	jsr $0073
        	; Hier wäre eine schöne Stelle, um den Programmverlauf zu protokollieren oder sonstwas zu machen.
        	cmp#$5f         ; Pfeillinks leitet alle neuen Befehle ein
        	beq .pfeilBefehl
        	jsr $0079		; Alle Register und Flaggen entsprechen dann wieder dem üblichen
        	jmp $a7e7   	; Original-Fortsetzung
.pfeilBefehl
 	       	jsr $0073		; ersten Buchstaben nach dem Pfeil holen, dient mir als Befehl
    	    inc $7a			; Ich verstehe nicht so recht, warum man das erhöhen muß...
        	bne .pf1
        	inc $7b
.pf1       	; hier sind nun alle neuen Befehle.
			; Ein paar Beispiele zum Holen von Parametern
			;-----
			cmp#"b"
	        bne .pf2
	        ; B-Kommando: Border-Farbe setzen
    	    jsr s_getByte
        	stx 53280
        	jmp $a7ae   ; Mainloop
			;-----
.pf2		cmp#"d"
	        bne .pf3
	        ; D-Kommando: Doppel-Poke. Adresse und Folgeadresse mit Word füllen
			;jsr frmevl	
			;clc
			;jsr s_typTesten	; Kracht, wenn was falsches übergeben wurde. Braucht man nicht in jedem Falle
			jsr s_getNumerisch 	; das Gleiche wie Eval+Check
			jsr s_facToWord
			lda $14
			pha
			lda $15
			pha
			jsr s_checkKomma
			jsr frmevl	
			jsr s_facToWord	; Ohne Typtest. Was passiert wohl bei Strings? ;)
			ldy $14
			ldx $15
			pla
			sta $15
			pla
			sta $14
			tya
			ldy#0
			sta ($14),y
			iny
			txa
			sta ($14),y
        	jmp $a7ae   ; Mainloop
			;-----
.pf3		cmp#"p"
	        bne .pf4
	        ; P-Kommando: String einfach so ins Screenram schreiben
			jsr frmevl	
			sec
			jsr s_typTesten		; Kracht, wenn was falsches übergeben wurde.
	        jsr s_stringAufbereiten
	        tay
	        beq .exit			; Bei leeren Strings passiert nichts
	        dey
.loop1      lda ($22),y
	        sta 1024,y
	        dey
	        cpy#255
	        bne .loop1
.exit      	jmp $a7ae   ; Mainloop
	        ;-----
.pf4		jmp s_synErr	; Der Rest ist wohl nix...

;--------------------------------------------------------------------------------
; Basic-Funktionen erkennen und verarbeiten
;--------------------------------------------------------------------------------
s_ieval
	        lda#0
    	    sta $0d 		; Init: Die Rückgabe ist numerisch, halt aus dem Original übernommen
        	jsr $0073
	        cmp#$5f 		;Pfeilinks
    	    beq .pfeilFunktion
	        jsr $0079
    	    jmp $ae8d   	; Original-Fortsetzung
 .pfeilFunktion
	        jsr $0073
	        ; Hier die neuen Funktionen
			;-----
    	    cmp#"l"
        	bne .pff2
	        ; Nimmt ein Byte mal zwei und gibt das Lo-Byte zurück
        	jsr $0073		; Das Gleiche wie oben.... Warum auch immer, ein Byte aus der Eingabe wird überlesen...
        	jsr s_checkKlammerAuf
        	jsr s_getByte
        	txa
        	pha
        	jsr s_checkKlammerZu
        	pla
        	asl
        	tay
        	jmp s_returnByteY
        	;-----
.pff2       cmp#"2"
        	bne .pff3
        	; Gibt ne 2 zurück, diesmal mit einer anderen Routine.
        	; Bin nicht 100%ig sicher, das die auch IMMER funktioniert!
        	jsr $0073
        	lda#2
        	jmp s_returnByteAkku    ; gibt Akku als Byte zurück

        	;-----
.pff3       cmp#"z"
        	bne .pff4
        	; Gibt die erste Zeile als temporären String zurück, aber nur bis 0-Byte oder Gänsefüßchen.
        	jsr $0073
        	lda#0
        	ldy#4
        	jmp s_returnString_Tmp
        	;-----
.pff4       cmp#"h"
        	bne .pff5
        	; Gibt den String "Hallo" als ordentlichen String zurück
        	jsr $0073
	        ; Platz für den String schaffen
    	    lda#5
        	jsr s_makeString ; $62 zeigt jetzt auf den freien Platz
        	ldy#4
.l1         lda ba_string,y
        	sta ($62),y
        	dey
        	bpl .l1
        	jmp s_returnString
        	;-----
.pff5       jmp s_synErr

ba_string   !text "Hallo"
    