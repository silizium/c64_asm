;32 bit multiply with 64 bit product

MULTIPLY:  lda     #$00
           sta     PROD+4   ;Clear upper half of
           sta     PROD+5   ;product
           sta     PROD+6
           sta     PROD+7
           ldx     #$20     ;Set binary count to 32
SHIFT_R:   lsr     MULR+3   ;Shift multiplyer right
           ror     MULR+2
           ror     MULR+1
           ror     MULR
           bcc     ROTATE_R ;Go rotate right if c = 0
           lda     PROD+4   ;Get upper half of product
           clc              ; and add multiplicand to
           adc     MULND    ; it
           sta     PROD+4
           lda     PROD+5
           adc     MULND+1
           sta     PROD+5
           lda     PROD+6
           adc     MULND+2
           sta     PROD+6
           lda     PROD+7
           adc     MULND+3
ROTATE_R:  ror     a        ;Rotate partial product
           sta     PROD+7   ; right
           ror     PROD+6
           ror     PROD+5
           ror     PROD+4
           ror     PROD+3
           ror     PROD+2
           ror     PROD+1
           ror     PROD
           dex              ;Decrement bit count and
           bne     SHIFT_R  ; loop until 32 bits are
           clc              ; done
           lda     MULXP1   ;Add dps and put sum in MULXP2
           adc     MULXP2
           sta     MULXP2
           rts


;64 bit divide routine with 32 bit quotent

DIVIDE:    ldy     #$40       ;Set bit length
DO_NXT_BIT: asl    DVDQUO
           rol     DVDQUO+1
           rol     DVDQUO+2
           rol     DVDQUO+3
           rol     DVDQUO+4
           rol     DVDQUO+5
           rol     DVDQUO+6
           rol     DVDQUO+7
           rol     DVDR+8
           rol     DVDR+9
           rol     DVDR+$a
           rol     DVDR+$b
           rol     DVDR+$c
           rol     DVDR+$d
           rol     DVDR+$e
           rol     DVDR+$f
           ldx     #$00
           lda     #$08
           sta     ADDDP
           sec
SUBT:      lda     DVDR+8,x   ;Subtract divider from
           sbc     DVDR,x     ; partial dividend and
           sta     MULR,x     ; save
           inx
           dec     ADDDP
           bne     SUBT
           bcc     NXT        ;Branch to do next bit
           inc     DVDQUO     ; if result = or -
           ldx     #$08       ;Put subtractor result
RSULT:     lda     MULR-1,x   ; into partial dividend
           sta     DVDR+7,x
           dex
           bne     RSULT
NXT:       dey
           bne     DO_NXT_BIT
           sec
           lda     DIVXP1     ;Subtract dps and store result
           sbc     DIVXP2
           sta     DIVXP2
           rts