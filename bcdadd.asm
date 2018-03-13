; da65 V2.16 - Git bea5364b
; Created:    2017-12-07 20:24:32
; Input file: bcdadd.bin
; Page:       1


        .setcpu "6502"
        .org $c000
        .word *
        .org *-2
        
        
        sei
        sed
        ldy     #$0F
        clc
L9005:  lda     $8000,y
        adc     $8010,y
        sta     $8000,y
        dey
        bpl     L9005
        cld
        cli
        rts

