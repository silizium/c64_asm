;Schnelle Multiplikation
;
;Die Idee stammt von Stephen Judd.
;Auch in »The Fridge« und im »C=Hacking Magazine« zu finden
;aber eigentlich eine Errungenschaft der alten Babylonier
;
;Wenn man f(x) = x^2 / 4 nimmt, dann
;
;ist      a*b = f(a+b) - f(a-b)
;wegen
;   (a+b)²/4-(a-b)²/4 =
;   a²/4+ab/2+b²/4  - a²/4-ab/2+b²/4 =
;   ab/2+ab/2 = ab   q.e.d.
;
;Die Multipliaktionstabellen für Quadrate sind natürlich 
;viel kürzer als die brutalen 256*256*2 Bytes (128k) einer 
;einfachen, geradlinigen Tabelle. Man braucht 2 Tabellen der 
;Quadrate mit 9 Bit Eingangsgröße und 16 Bit Ergebnisgröße
;Das sind 4*256 Bytes
;
;Das Bilden des Zweierkomplements üblicherweise durch
;
;   EOR #$ff
;   CLC
;   ADC #1
;
;läßt sich durch Verschieben von Tabelle 1 um ein Byte
;runter und das Bilden des einfachen Komplements vereinfachen
;
;   EOR #$ff
;
;Dieser Algorithmus ist besonders nützlich, wenn man 
;Zahlen mehrfach mit dem selben Faktor multiplizieren 
;möchte. Dann kann man die zp Adresse des Multiplikators
;nämlich belassen und braucht jeweils nur das Y-Register 
;zu verändern. 
;Mit dem selben Trick läßt sich der Algorithmus auch einfach
;auf 16 Bit erweitern. Wenn man allerdings schnell sein will,
;braucht man dann mehr als 8 Zeropage Adressen.
.export bcdtest, bcd2bin, bcdmultab

stack=$100

zp1=$20    			;8 Bytes ZP Indexzeiger
zp2=$22
zp3=$24
zp4=$26

tab1=$4000 			;2 kBytes Quadrattabellen
tab2=$4200
tab3=$4400
tab4=$4600

        ;Argumente Akku+Y-Register als Multiplikator und Multiplikant
	;vor erstem Aufruf Routine "initmultab" aufrufen, um die Tabellen
	;zu berechnen
	;Ergebnis: lo - X-Register  hi - Akku

.proc bcdtest
	multiplikant	=stack+3	;stack+1 u. +2=jsr-Adresse
	multiplikator	=stack+4
		lda #>bcdmultab1lo
		sta zp1+1
		lda #>bcdmultab1hi
		sta zp2+1
		tsx
		lda multiplikant,x
		sta zp1
		sta zp2
		lda multiplikator,x  
		tay
		lda (zp1),y
		tax
		lda (zp2),y
		rts
.endproc

.proc bcd2bin				;Argument im Accu
		tsx
		tay
		and #$f0
		lsr
		sta stack,x
		lsr
		lsr
		adc stack,x
		sta stack,x
		tya
		and #$0f
		adc stack,x
		rts
.endproc

.proc bcdmultab
		sta zp1     	;Zeropage Adressen setzen
		sta zp2
		eor #$ff
		sta zp3
		sta zp4

		sei
		sed
		sec
		lda (zp1),y
		sbc (zp3),y
		tax         	;lo-Prokukt in X-Register
		lda (zp2),y
		sbc (zp4),y 	;hi-Produkt in Akku
		cld
		cli

		rts
.endproc

        
        ;Die Grundidee der verwendeten Quadrattabellen ist:
        ;  x²/4 = (x-1)²/4 + x/2 -1 =
        ;  x²   = (x-1)² + 2x    -1 =
        ;  x²   = x²-2x+1+ 2x    -1 =
        ;  x²   = x²+1           -1 =
        ;  x²   = x²
        ; mit (x-1) läßt sich der vorherige Tabellenwert weiterverwenden
        ; wodurch eine einfache Reihe entsteht
bcdmultab1lo: 	.repeat 26, ZEHN
		.repeat 16, EIN
		 .byte (((ZEHN+EIN)*(ZEHN+EIN)/4 .mod 100)/10)*16+((ZEHN+EIN)*(ZEHN+EIN)/4) .mod 10
		.endrep
		.endrep
bcdmultab1hi: 	.repeat 26, ZEHN
		.repeat 16, EIN
		 .byte (((ZEHN+EIN)*(ZEHN+EIN)/400)/10)*16+((ZEHN+EIN)*(ZEHN+EIN)/400) .mod 10
		.endrep
		.endrep
bcdmultab2lo: 	.repeat 26, ZEHN
		.repeat 16, EIN
		 .byte (((ZEHN+EIN)*(ZEHN+EIN)/4 .mod 100)/10)*16+((ZEHN+EIN)*(ZEHN+EIN)/4) .mod 10
		.endrep
		.endrep
bcdmultab2hi: 	.repeat 26, ZEHN
		.repeat 16, EIN
		 .byte (((ZEHN+EIN)*(ZEHN+EIN)/400)/10)*16+((ZEHN+EIN)*(ZEHN+EIN)/400) .mod 10
		.endrep
		.endrep

;bcdmultab1hi: 	.repeat 253, I
		;.if I*I<=9999*4
;		  .byte (((I*I)/400)/10)*16+((I*I)/400) .mod 10
		;.else
		;  .byte $ff
		;.endif
;		.endrep
