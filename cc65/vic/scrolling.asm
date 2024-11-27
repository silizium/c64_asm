#!acme -f cbm -o scrolling.prg scrolling.asm
;###############################################################################
;# Programm:      Horizantales Soft-Scrolling des gesamten Bildschirms
;# Dateiname:     scrolling.asm
;#
;# Assembler:     ACME
;# Assemblierung: acme -f cbm -o scrolling.prg scrolling.asm
;#
;# Start mit:     RUN
;#
;# Quelltext:     * Kleinschreibung (bis auf Kommentare)
;#                * nur Leerzeichen, keine Tabulatoren
;#                * Abstand: jeweils 20 Zeichen (Label --> Befehl --> Kommentar)
;#                * Zeilenlänge max. 80 Zeichen
;#
;# Beschreibung:  Scrollt den gesamten Bildschirm (Soft- und Hardscrolling)
;#
;###############################################################################

; ----- @Basic-Start@ -----

                    *=$0801             ; Basic-Startzeile "10 SYS2061" erzeugen
                    !word +             ; Zeiger auf nächste Basic-Zeile
                    !word 10            ; Basic Zeilennummer
                    !byte $9e           ; Basic-Token für SYS-Befehl
                    !text "2061"        ; Startadresse des Programms: 2061/$080D
                    !byte 0             ; Basic-Zeilenende
+                   !word 0             ; Basic-Programmende

; ----- @Start@ -----

start:              sei                 ; Interrupts sperren

                    lda #%00000111      ; Bit 5-7: unbenutzt
                                        ; Bit 4:   0 = Multicolormodus aus  
                                        ; Bit 3:   0 = 38 Spalten
                    sta $d016           ; Bit 0-2: X-Pixeloffset vom linken Rand

; ----- @Softscrolling@ -----

                    ldx #7              ; 7x Softsrcollen
softscroll:         lda #251
-                   cmp $d012           ; auf Rasterzeile 251 warten
                    bne -
-                   cmp $d012           ; auf Ende von Rasterzeile 251 warten
                    beq -

                    dec $d016           ; Softscrolling um einen Pixel links
                    dex
                    bne softscroll      ; wiederhole, bis Register=0

; ----- @hardscrolling@ -----

                    lda #60             ; Warte auf Rasterzeile 60
-                   cmp $d012
                    bne -

hardscroll:         ldx #<$0400         ; Zeiger ($fb) auf $0400
                    stx $fb             
                    inx
                    stx $fd             ; Zeiger ($fd) auf $0401
                    ldx #>$0400
                    stx $fc
                    stx $fe

                    ldx #24             ; Anzahl der zu scrollenden Zeilen
naechste_zeile:     ldy #0

                    lda ($fb), y
                    pha                 ; linkes Zeichen der Zeile auf Stapel

-                   lda ($fd), y        ; alle 39 Zeichen um eine Position
                    sta ($fb), y        ; nach links kopieren
                    iny
                    cpy #39             ; Zeilenende erreicht?
                    bne -

                    pla                 ; Zeichen vom Stapel holen
                    sta ($fb), y        ; und am Zeilenende einfügen

                    clc
                    lda $fb             ; Quellzeiger ($fb)
                    adc #40             ; um 40 Zeichen (eine Zeile) erhöhen
                    sta $fb
                    bcc +
                    inc $fc                    
                    
+                   clc
                    lda $fd             ; Zielzeiger ($fd)
                    adc #40             ; um 40 Zeichen (eine Zeile) erhöhen
                    sta $fd
                    bcc +
                    clc
                    inc $fe

+                   dex
                    bne naechste_zeile  ; Letzte Zeile schon erreicht?

                    jmp start           ; Endlosschleife

