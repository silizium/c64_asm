         *= $1000

         JSR $E544 ; CLEAR SCREEN

NUMSTARS = 10 ;MIN 1 MAX 10

         SEI       ; DISABLE INT

         LDA #$00
         CMP $D012
         BNE *-3

         STA $D020 ; SET BORDER TO 0

         LDA #$80
         STA $07F8 ;SPR POINT 1
         LDA #$01
         STA $D015 ;ENABLE SPR1

         LDA #$01
         STA $D01B ;SPR PRIORITY

MLOOP
         LDX #0
LOOPSTAR
         LDA STARFLD1,X
         CMP $D012
         BNE *-3

         CLC     ; ADD SPACE BETWEEN
         ADC #2  ; CUR RAST AND SPRITE

         STA $D001       ; Y
         LDA STARFLD2,X
         STA $D027       ; SPRITE COLOR1

         INX
         JSR MOVESTARS

         LDA STARFLD1,X
         STA $D000       ; X
         LDA STARFLD2,X
         STA $D010       ; X HIGH BIT

         INX             ;
         CPX #NUMSTARS*2
         BNE LOOPSTAR

         JMP MLOOP



MOVESTARS
         LDA STARFLD1,X
         CLC
         ADC STARFLD3,X ; ADD X
         TAY
         STA STARFLD1,X
         BCC CHECKHBIT  ; CHECK IF 0
         LDA #$01       ; SET X HI BIT
         STA STARFLD2,X
         RTS
CHECKHBIT
         LDA STARFLD2,X ; CHECK X HI BIT
         BNE CHECKBORD
         RTS
CHECKBORD
         CPY #$50 ; CHECK RIGHT BORDER
         BPL RESETPOSX
         RTS
RESETPOSX
         LDA #0
         STA STARFLD2,X ; RESET X HI BIT
         STA STARFLD1,X ; RESET X

         RTS


STARFLD1 ; XX/YY
         .WORD $7435,$304A,$745F,$8274
         .WORD $3389,$E79E,$A5B4,$41C9
         .WORD $21DE,$82F4

STARFLD2 ; X HI BIT/ COLOUR
         .WORD $0B,$010C,$0F,$0C
         .WORD $0B,$0C,$0B,$010C
         .WORD $010F,$0C
STARFLD3 ; STAR SPEED / UNUSED
         .WORD $0100,$0200,$0300,$0200
         .WORD $0100,$0200,$0100,$0200
         .WORD $0300,$0100
SPR1DATA
         *= $2000
         .BYTE $80


