;--------------------------------
;JCH, DMC, Whatever IRQ music plr
;================================

             !to "irqmusplr.prg",cbm
             .org $0810 ;Remember SYS 2064 to enable it
             sei
             lda #<irq
             ldx #>irq
             sta $314
             stx $315
             lda #$1b
             ldx #$00
             ldy #$7f 
             sta $d011
             stx $d012
             sty $dc0d
             lda #$01
             sta $d01a
             sta $d019 ; ACK any raster IRQs
             lda #$00
             jsr $1000 ;Initialize Richard's music
             cli
hold         jmp hold ;We don't want to do anything else here. :)
                      ; we could also RTS here, when also changing $ea81 to $ea31
irq
             lda #$01
             sta $d019 ; ACK any raster IRQs
             jsr $1003 ;Play the music
             jmp $ea31
            

             * = $1000-2
             !binary "music.dat" ;Rip one of my tunes from the HVSC and save as music.dat if you like :)
