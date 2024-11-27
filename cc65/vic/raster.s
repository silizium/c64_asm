RASTER = $20

;*** Startadresse 
*=$0801
;** BASIC-Zeile: 2018 SYS 2064:NEW
 !word main-2, 2018 
 !byte $9e
 !text " 2064:"
 !byte $a2,$00,$00,$00

main
 sei                                ;IRQs sperren

 lda #<myIRQ                        ;Adresse unserer Routine in
 sta $0314                          ;den RAM-Vektor
 lda #>myIRQ
 sta $0315

 lda #%00000001                     ;Raster-IRQs vom VIC-II aktivieren
 sta $d01a

 lda #RASTER                        ;Hier soll unsere Linie erscheinen
 sta $d012                      

 lda $d011                          ;Zur Sicherheit höchstes BIT
 and #%01111111                     ;für die Rasterzeile löschen
 sta $d011

 lda #%01111111                     ;Timer-IRQs abschalten
 sta $dc0d
 lda $dc0d                          ;zur Sicherheit bestätigen

 lda #%00000001                     ;Sicherheitshalber auch den
 sta $d019                          ;Raster-IRQ bestätigen

 cli                                ;Interrupts erlauben

 rts                                ;zurück zum BASIC



;*** Platz für ein kleines BASIC-Programm lassen: 
;*** z. B. 10 PRINT "HALLO ";:GOTO 10 
!align 1023,0
myIRQ
;*** Wenn wir hier landen, sind bereits 38-45 Taktzyklen
;*** in der aktuellen Rasterzeile (20) vergangen!

;*** Zweiten IRQ einrichten.
;*** Da die Zeit bei aktivierten ROM nicht reicht,
;*** können wir den 2. Raster-IRQ erst in der übernächsten Zeile bekommen!
 lda #<doubleIRQ                    ;(2 TZ) 2. Raster-IRQ einrichten
 sta $0314                          ;(4 TZ)
 lda #>doubleIRQ                    ;(2 TZ)
 sta $0315                          ;(4 TZ)
 tsx                                ;(2 TZ) Stackpointer im X-Reg. retten
 stx doubleIRQ+1                    ;(4 TZ) und fürs zurückholen sichern!
 nop                                ;(2 TZ)
 nop                                ;(2 TZ)
 nop                                ;(2 TZ)
 lda #%00000001                     ;(2 TZ) 1. Raster-IRQ später bestätigen
                                    ;------
                                    ;26 TZ

;*** Jetzt sind 64-71 Taktzyklen vergangen und wir sind
;*** auf jeden Fall in nächsten Rasterzeile (21)!
;*** Verbraucht wurden dort 1-8 TZ
 inc $d012                          ;(6 TZ) 2. IRQ in der übernächsten Zeile (22)!!!
                                    ;       $d012 wurde bereits automatisch erhöht
 sta $d019                          ;(4 TZ) IRQ bestätigen
 cli                                ;(2 TZ) Interrupts für den 2. Raster-IRQ
                                    ;       wieder freigeben
                                    
;*** Wir befinden uns in Rasterzeile 21 und 
;*** haben bisher 13-20 Zyklen verbraucht

;*** etwas Zeit verschwenden...
 ldx #$08                           ;            2 TZ
loop
 dex                                ;8 * 2 TZ = 16 TZ
 bne loop                           ;7 * 3 TZ = 21 TZ
                                    ;1 * 2 TZ =  2 TZ
                                    ;          ------
                                    ;           41 TZ

;*** Bis hier sind 54-61 Taktzyklen vergangen, jetzt auf den IRQ warten...
;*** Der nächste Rasterinterrupt wird während dieser NOPs auftreten!
 nop                                ;2 TZ (56)
 nop                                ;2 TZ (58)
 nop                                ;2 TZ (60)
 nop                                ;2 TZ (62)
 nop                                ;2 TZ (64)
 nop                                ;2 TZ (66)

doubleIRQ
;*** Wir sind nun in Rasterzeile 22 und
;*** haben in dieser genau 38 oder 39 Taktzyklen benötigt!!
;*** Wir können so sicher sein, da der IRQ während der NOPs auftrat.

;*** Jetzt exakt soviele Taktzyklen 'verschwenden', wie in 
;*** dieser Zeile noch zu verarbeiten sind (also 24 oder 25).
 ldx #$00                           ;(2 TZ) Platzhalter für 1. Stackpointer
 txs                                ;(2 TZ) Stackpointer vom 1. IRQ wiederherstellen
 nop                                ;(2 TZ)
 nop                                ;(2 TZ)
 nop                                ;(2 TZ)
 nop                                ;(2 TZ)
 bit $01                            ;(3 TZ)
 ldx $d012                          ;(4 TZ)
 lda #$01                           ;(2 TZ) weiß schonmal in den Akku

 cpx $d012                          ;(4 TZ) sind wir noch in Rasterzeile 22?
                                    ;------
                                    ;25 TZ = 63 oder 64 TZ!!!

 beq myIRQMain                      ;(3 TZ) wenn JA einen letzten Takt 'verschwenden'
                                    ;(2 TZ) sonst einfach weiterlaufen...

;*** Wir beginnen also immer exakt nach 3 TZ in der dritten Rasterzeile (23)
;*** nach dem 1. Raster-IRQ (den hatten wir ja in für Zeile 20 festgelegt)

myIRQMain
 sta $d020                          ;Rahmenfarbe setzen

 ldx #$0a                           ;            2TZ
loop2
 dex                                ;10 * 2TZ = 20TZ
 bne loop2                          ; 9 * 3TZ = 27TZ
                                    ; 1 * 2TZ =  2TZ
 nop                                ;            2TZ
 nop                                ;            2TZ
 nop                                ;            2TZ
 lda #$00                           ;            2TZ ;schwarz in den Akku
 sta $D020                          ;            4TZ ;Rahmenfarbe setzen
                                    ;===============
                                    ;           63TZ

 lda #<myIRQ                        ;Original IRQ-Vektor setzen
 sta $0314
 lda #>myIRQ
 sta $0315

 lda #RASTER                        ;ursprüngliche Rasterzeile zurücksetzen
 sta $d012

 lda #%00000001                     ;IRQ bestätigen
 sta $d019

 jmp $ea31                          ;zum Schluß zum 'Timer-Interrupt' springen
