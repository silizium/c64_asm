; send sendet eine 64er-File über den Userport an
; den Amiga
; (Centronics-Routinen)

;------------------------------
;include 'HardwareVectoren.sub'
;------------------------------

;Hardware IO
vic	= $d000
sid 	= $d400
colram	= $d800
cia1	= $dc00
cia2	= $dd00

;CIA Register Offsets
cia_pra	= 0	;Port A
cia_prb	= 1	;Port B
cia_ddra	= 2	;Port A Richtungsregister 0-Ein 1-Aus
cia_ddrb	= 3	;Port B Richtungsregister 0-Ein 1-Aus
cia_ta	= 4	;Timer A, low, hi
cia_tb	= 6	;Timer B, low, hi
cia_tod	= 8	;TimeOfDay 10tel, sec, min, hr
cia_sdr	= 12	;Serial Data Register
cia_icr	= 13	;Interrupt Control Register
cia_cra	= 14	;Control Register a
cia_crb	= 15	;Control Register b

cia_flag	= %00010000

;Einsprünge im Kernel
resvid	= $ff81	;Video-Reset
rescia	= $ff84	;CIA initialisieren
resram	= $ff87	;RAM löschen/testen
resio	= $ff8a	;IO initialisieren
resiov	= $ff8d	;IO-Vektoren initialisieren
setstatus	= $ff90	;status setzten
seclisten	= $ff93	;Sekundäradresse nach listen
sectalk	= $ff96	;Sekundäradresse nach talk
ramend	= $ff99	;RAM-Ende setzen/holen
ramstart	= $ff9c	;RAM-Anfang setzen/holen
checkkey	= $ff9f	;Tastatur abfragen
iectimeout	= $ffa2	;IEC Timeout-Flag setzen
iecin	= $ffa5	;Eingabe vom IEC-Bus
iecout	= $ffa8	;Ausgabe auf IEC-Bus
iecuntalk	= $ffab	;UNTALK senden
iecunlisten   = $ffae	;UNLISTEN senden
ieclisten	= $ffb1	;LISTEN senden
iectalk	= $ffb4	;TALK senden
getstatus	= $ffb7	;status holen, im Akku
setfls	= $ffba	;Fileparameter setzten, 
		;a-filenr, x-gerätenr, y-sekundäradr
setnam	= $ffbd	;Filenamenparameter setzten
		;a-länge x-low y-hi
open	= $ffc0	;clc ->ok sec->error (Fortg. S.181)
close	= $ffc3
chkin	= $ffc6	;Eingabegerät setzten, x=Kanal
ckout	= $ffc9	;Ausgabegrät setzen, x=Kanal
clrch	= $ffcc	;Ein/Ausgabe rücksetzen, immer eq
input	= $ffcf	;Eingabe eines Zeichens
print	= $ffd2	;Ausgabe eines Zeichens
load	= $ffd5
save	= $ffd8
settime	= $ffdb	;Time setzen
gettime	= $ffde	;Time holen
checkstop	= $ffe1	;Stop-Taste abfragen eq->stop
get	= $ffe4
clall	= $ffe7
inctime	= $ffea	;Time erhöhen
getscreen	= $ffed	;Anzahl der Zeilen/Spalten holen
setcursor	= $fff0	;Cursor setzen(clc)/holen(sec) x/y
getio	= $fff3	;Startadresse des IO-Bausteins holen

saveregister	= $e147	;SYS-Befehl: Register abspeichern
resscr	= $e518	;reset Bildschirm/Tastatur
clrscr	= $e544	;Bildschirm löschen
crsrhome	= $e566	;Cursor home
calccrsr	= $e56c	;Cursorposition berechnen
initvid	= $e5a0	;Videocontroller mit Standard
getkey	= $e5b4	;Zeichen aus Tastaturpuffer
waitkey	= $e5ca	;wartet auf Tastatureingabe
printscreen	= $e716	;Zeichen auf Bildschirm ausgeben
scrollup	= $e8ea	;Scrollt Bildschirm nach oben
clrline	= $e9ff	;löscht einen Zeile
putchar	= $ea1c	;setzt Zeichen a-Bildschirmcode x-Farbe

;Basic-Routinen
strin	= $a560	;holt Zeile nach $200
strout	= $ab1e 	;a-lo y-hi
errorout	= $a437	;Basic-Warmstart Errornummer in a
uintout	= $bdcd	;Ausgabe von uint in lo-X/hi-A

;Numerische Routinen aus der Basiczeile (Anfänger 155)
getbyt	= $b79e		
frmnum	= $ad8a
getadr	= $b7f7
chkcom	= $aefd
chrgot	= $0079
chrget	= $0073
getpar	= $b7eb
frmevl	= $ad9e	;allgemeine Formelauswertung (Intern 87)

;(Fortgeschrittene)
;Fließkomma-Routinen
;wandlungen
ascfloat	= $bcf3	;lo-$7a hi-$7b jsr chrgot, dann round
round	= $bc1b	;nach Wandlung runden
float2int	= $bc9b	;hi$62-$65, wenn exp($61)<$a0
float2asc	= $bddd	;legt ASCII-Zahl ab $100 ab a-lo y-hi
byte2fl	= $bc3c	;a-byte
ubyte2fl	= $b3a2	;y-byte
word2fl	= $b395	;y-lo a-hi
uword2fl	= $bc49	;$63-lo $62-hi x-#$90 sec
lword2fl	= $bc4f	;siehe Fort Seite 26
ulword2fl	= $bc4f	;sec a-#0 x-#$a0 hi$62-$65

;Rechnen
argtofac	= $bbfc
factoarg	= $bc0c
flplus	= $b86a	;FAC=ARG+FAC
flminus	= $b853	;FAC=ARG-FAC
flmul	= $ba28	;FAC=ARG*FAC
fldiv	= $bb12	;FAC=ARG/FAC
flpot	= $bf7b	;FAC=ARG^FAC

;----------------------------------------------------------
;Systemkonstanten (nach 'The Commodore 64 Marco-Assembler')
; Zeropage und anderes
;----------------------------------------------------------
txttab	= $2b	;Zeiger auf Basic-Prgrammstart
vartab	= $2d	;Zeiger auf Start der Variablen
arytab	= $2f	;Zeiger auf Start der Arrays
strend	= $31	;Zeiger auf Ende der Arrays
fretop	= $33	;Zeiger auf Start der Strings

facexp	= $61	;Fließkommaakku 1 Exponent
facho	= $62	; -$65 Mantisse
facsgn	= $66	; Vorzeichen
argexp	= $69	;Fließkommaakku 2 Exponent
argho	= $9a	; -$9d Mantisse
argsgn	= $9e	; Vorzeichen

direct_mode	= $9d	;Flag für Direktmodus $80, Programm $00
tape_checksum1	= $9e	;Checksumme für Band Pass1
tape_checksum2	= $9f	;Fehlerkorrektur für Band Pass2

pointer1	= $fb	;$fb/$fc
pointer2	= $fd	;$fd/$fe

ascbuffer	= $100
stack	= $100	;Prozessorstack
inputbuffer	= $200	;BASIC Eingabepuffer
sareg	= $30c	;Akku für SYS-Befehl
sxreg	= $30d	;x-Register
syreg	= $30e	;y-Register
spreg	= $30f	;Status-Register

irq_vector	= $314	;IRQ-Vektor
brk_vector	= $316	;Break-Vektor

;----------------------------
; Ende 'HardwareVectoren.sub'
;----------------------------

	*= $c000

;*************************************************************************
;Protokoll:
;  Filename,0,Bytes lo,Bytes hi,data...,checksum(lo,hi,data),weitere=255/0
;*************************************************************************

	jmp startsend		;SYS12*4096

;Files vom Amiga empfangen
startreceive	lda #<textreceive	;SYS12*4096+3
	ldy #>textreceive
	jsr strout		;Begrüßungstext
	lda #<wartefiletext	;Warte auf File-Text
	ldy #>wartefiletext
	jsr strout

	jsr syncin		;Syncronisieren
	
	ldx #-1
wartename	inx
	jsr centrin		;hole den filenamen
	sta inputbuffer,x
	bne wartename

	lda #<filenametext	;Text ausgeben
	ldy #>filenametext
	jsr strout
	lda #<inputbuffer	;Filenamen ausgeben
	ldy #>inputbuffer
	jsr strout

	jsr centrin		;Länge lo	
	sta pointer1
	jsr startchecksum
	jsr centrin		;Länge hi
	sta pointer1+1
	jsr checksum
	jsr showlen

	jsr openfile		;File öffnen

	lda #<laeufttext	;Empfangsmeldung
	ldy #>laeufttext	; ausgeben
	jsr strout

holefile	sec		;Schleifenzähler
	lda pointer1		;lo-Byte
	sbc #1		;dekrementieren
	sta pointer1
	bcs keinuebertrag
	lda pointer1+1	;auch hi-Byte
	sbc #0		;dekrementieren
	sta pointer1+1
	bcc endholefile	;bei Null ende
	lda #'.		;Bei jedem vollen Block
	jsr print		; '.' ausgeben
keinuebertrag	jsr checkstop		;Stoptaste abfragen
	beq endholefile
	ldx #1		;Print nach File
	jsr ckout
	jsr centrin		;Zeichen in a
	jsr checksum		;zur Checksumme addieren
	jsr print		;und in File schreiben
	jsr clrch		;wieder nach Bildschirm
	beq holefile		;ist immer eq nach clrch

endholefile	jsr closefile		;und schließen

	lda #<endtransmittxt
	ldy #>endtransmittxt
	jsr strout

	jsr centrin		;Checksumme holen
	jsr checkchecksum	;Checksumme überprüfen

	jsr centrin		;Weitere Files?
	beq receiveend
	jmp startreceive	;dann wieder zum Start
	
receiveend	rts		;sonst Ende

;-------------------------------------------------------------------------

;Syncronisation zu Begin
syncin	lda #$00		;Eingabe
	sta cia2+cia_ddrb	;von Parallelport
	lda cia2+cia_prb	;Port löschen

synci1	ldx #5		;Warten auf 5 Nullbytes
synci2	jsr centrin
	bne synci1
	dex
	bne synci2
	
synci3	jsr centrin		;Nullbytes überlesen
	beq synci3		;Warten auf Countdown

	sta pointer2		;Zwischenspeichern
	dec pointer2
synci4	jsr centrin		;Countdown 987654321
	cmp pointer2
	bne synci1		;Fehler im Countdown
	dec pointer2
	bne synci4
	rts

;-------------------------------------------------------------------------

;Zeichen Eingabe von Centronics in den Akku
centrin 	lda cia2+cia_icr	;Interrupt Control Register lesen
	and #cia_flag		;Daten gebracht?
	beq centrin		;sonst warten
	
	lda cia2+cia_prb	;Lesen
	rts			;ok

;-------------------------------------------------------------------------

;öffnet File oder verläßt das Programm
openfile	jsr strlen		;strlen in x
	txa		; nach a
	ldx #<inputbuffer
	ldy #>inputbuffer
	jsr setnam		;Filenamen setzen
	lda #1		;Filenummer		
	ldx #8		;Geräteadresse
	ldy #2		;Sekundäradresse
	jsr setfls		;Fileparameter setzten
	jsr open		;und öffnen
	bcc openok
	jmp errorout		;Fehler und Ende
openok	rts

;-------------------------------------------------------------------------

;schließt das File wieder
closefile	lda #1
	jmp close

;-------------------------------------------------------------------------

;holt Stringlänge des inputbuffer nach x
strlen	ldx #-1
strlen1	inx
	lda inputbuffer,x
	bne strlen1
strlen2	rts

;-------------------------------------------------------------------------

;Gibt die Filelänge aus
showlen	lda #<lentext		;Filelängentext ausgeben
	ldy #>lentext
	jsr strout
	ldx pointer1		;x = lo
	lda pointer1+1	;a = hi
	jsr uintout		;Länge ausgeben
	lda #13
	jsr print		;mit Return abschließen
	rts

;-------------------------------------------------------------------------
;Unterroutinen für die Checksumme

startchecksum	sta tape_checksum1	;Checksumme initialisieren
	rts

checksum	pha		;Akku retten
	clc
	adc tape_checksum1	;Checksumme addieren
	sta tape_checksum1
	pla		;Akku wiederherstellen
	rts

checkchecksum	cmp tape_checksum1
	bne checkerror	;Fehler in der Checksumme?
	lda #<checkoktxt	;Chechsum ok
	ldy #>checkoktxt
	jmp strout		;ok
checkerror	lda #<checkerrortxt
	ldy #>checkerrortxt
	jmp strout		;Fehler

checksend	lda tape_checksum1
	jsr centrout
	rts

;-------------------------------------------------------------------------

textreceive	.byte 13,"RECEIVE-CENTRONICS-ROUTINEN",13
		.byte "VON H.BEHRENS (C)1991",13,0
wartefiletext	.byte "WARTE AUF FILE...",13,0
filenametext	.byte "FILENAME:",0
lentext		.byte 13,"LAENGE  :",0
laeufttext	.byte 13,"UEBERTRAGUNG LAEUFT.",0
endtransmittxt	.byte 13,"UEBERTRAGUNG BEENDET.",13,0
checkoktxt	.byte "CHECKSUMME OK.",13,0
checkerrortxt	.byte "FEHLER IN DER CHECKSUMME.",13,0

;*************************************************************************

;Files zum Amiga senden
startsend	lda #<textsend	;Begrüßungstext
	ldy #>textsend
	jsr strout		;ausgeben
	lda #<filenametext	;Aufforderung
	ldy #>filenametext	; zum Eintippen des
	jsr strout		; Filenamen
	jsr strin		;Zeile mit Filenamen holen

	jsr openfile		;File öffnen

	jsr syncout		;Syncronisation

	ldx #-1		;Filenamen senden
sendname	inx
	lda inputbuffer,x	;Filenamen holen
	jsr centrout		;und senden
	bne sendname		;bis Null-Byte = Abschluß

	jsr loadfile		;File in den Speicher
	jsr showlen		;Filelänge anzeigen
	jsr sendfile		;File zum Amiga senden		
	jsr closefile		;und schließen

	lda #<endtransmittxt
	ldy #>endtransmittxt
	jsr strout

	jsr nochmal		;weitere Files senden
	bne startsend		; dann wieder zum Anfang

;	ldx #0		;am Schluß 
;	txa		; den PAR:-Buffer des
;sendfillbuffer	jsr centrout	; Amiga mit
;	dex		; Nullen füllen
;	bne sendfillbuffer	; 

	rts		;Ende

;-------------------------------------------------------------------------

;wenn a=pos sendet er das File, sonst Filelänge in pointer1
loadfile	lda #<loadingtxt	;Loading... ausgeben
	ldy #>loadingtxt
	jsr strout

	lda #0		;Die Filelängen-
	sta pointer1		; zähler
	sta pointer1+1	; löschen

	lda strend		;Anfang 
	sta pointer2		; im Speicher hinter
	lda strend	+1	; das Basic setzen
	sta pointer2+1	; wenn zuwenig Speicher, dann Pech gehabt

	ldx #1		;Eingabe (get)
	jsr chkin		; von File

sfl1		jsr getstatus	;Schleifenanfang
	cmp #64		;Fileende?
	beq sflend		; dann Schleife verlassen
	jsr checkstop		;Stoptaste?
	beq sflend		; dann Schleife verlassen
	inc pointer1		;16 Bit Zeichen zählen
	bne sfl2		;übertrag?
	inc pointer1+1	; dann Highbyte inkrementieren
sfl2		jsr get	;Zeichen in a aus File holen
	ldy #0
	sta (pointer2),y	;Speichern	
	inc pointer2		; und Pointer erhöhen
	bne sfl3
	inc pointer2+1
sfl3		jmp sfl1	;Schleife wiederholen

sflend		jsr clrch	;Kanal löschen
	rts

;-------------------------------------------------------------------------
sendfile	lda #<laeufttext	;Sendemeldung
	ldy #>laeufttext
	jsr strout		; ausgeben

	lda pointer1
	jsr startchecksum	;Checksumme erstellen
	jsr centrout		; lo senden
	lda pointer1+1
	jsr checksum
	jsr centrout		; hi senden

	lda strend		;Pointer auf Daten setzen
	sta pointer2
	lda strend	+1
	sta pointer2+1

sendf1	lda pointer1
	ora pointer1+1
	beq sendf3		;Ende von den Daten erreicht

	ldy #0
	lda (pointer2),y
	jsr checksum
	jsr centrout

	inc pointer2		;Zeiger auf Daten inkrementieren
	bne sendf2
	inc pointer2+1

sendf2	sec		;Filelänge dekrementieren
	lda pointer1
	sbc #1
	sta pointer1
	bcs sendf1
	dec pointer1+1
	lda #'.
	jsr print
	jmp sendf1

sendf3	jsr checksend		;Checksumme senden
	rts

;-------------------------------------------------------------------------

;Syncronisation zu Beginn
syncout	ldy #$ff		;Parallelport
	sty cia2+cia_ddrb	; auf Ausgang schalten
	ldx #20		;erstmal 20 Nullbytes
	lda #0
synco2	jsr centrout
	dex
	bne synco2
	
	ldx #9		;Countdown 987654321
synco3	txa		
	jsr centrout
	dex
	bne synco3
	rts

;-------------------------------------------------------------------------

;Zeichen im Akku auf Userport ausgeben (Centronics)
; y wird verändert

centrout	sta cia2+cia_prb	;Schreiben
	tay			;Akku retten
centrloop1	lda cia2+cia_icr	;Interrupt Control Register lesen
	and #cia_flag		;Daten geholt?
	beq centrloop1	;sonst warten
	tya		;Akku wiederherstellen
	rts		;ok

;-------------------------------------------------------------------------
;Abfrage auf Wiederholung
nochmal	lda #<nochmaltxt
	ldy #>nochmaltxt
	jsr strout		;Abfragetext ausgeben
	
noch1	jsr get
	beq noch1
	
	tax		;Akku retten
	cmp #'J
	beq noch2
	cmp #'N
	beq noch3
	bne noch1

noch2	ldx #$ff		;Weitere Files senden
	.byte $2c		;BIT $xxxx
noch3	ldx #0
	jsr print
	lda #13
	jsr print
	txa
	jsr centrout	
	rts

;-------------------------------------------------------------------------

textsend	.byte 13,"SEND-CENTRONICS-ROUTINEN",13
	.byte "VON H.BEHRENS (C)1991",13,0
loadingtxt	.byte "LOADING FILE...",13,0
nochmaltxt	.byte "NOCH EIN FILE (J/N)? ",0
.end
