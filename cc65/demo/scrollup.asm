;Upward scroll with raster IRQ by Richard/TND

row = $0400

!to "upwardscroll.prg",cbm

* = $0801
!basic 2064
* = $0810 

;Reset scroll text

lda #<scrollText 
sta messRead+1
lda #>scrollText 
sta messRead+2

;Kernal clear and fill screen with crsr white

lda #$05
jsr $ffd2
jsr $e544

lda #$00
sta $d020
sta $d021

;Prepare interrupts

ldx #<irq
ldy #>irq
lda #$7f
stx $314
sty $315
sta $dc0d
sta $dd0d
lda #$2a
sta $d012
lda #$1b
sta $d011
lda #$01
sta $d019
sta $d01a
cli
jmp mainLoop

;IRQ 1 - Mask out the top+bottom row for upscroll appearance
;and generate raster timer (RT), which can be synced with
;mainLoop

irq 
inc $d019
lda #$32
sta $d012
lda #$70 
sta $d011
lda #1
sta rt
ldx #<irq2
ldy #>irq2
stx $0314
sty $0315
jmp $ea7e

;IRQ 2 smooth scroller     

irq2
inc $d019
lda #$f2 
sta $d012
lda ypos
ora #$10
sta $d011
ldx #<irq
ldy #>irq
stx $0314
sty $0315
jmp $ea7e

;Main loop for controlling my demonstration

mainLoop
lda #0
sta rt
cmp rt
beq *-3
jsr upScroll
jmp mainLoop

;Upscroll routine 

upScroll lda ydelay ;Control delay
cmp #3
beq loop01
inc ydelay
skipScroll
rts 

loop01 lda #0
sta ydelay
lda ypos
sec
sbc #1
and #7
sta ypos ;This will store YPOS, but in your IRQ you will need to add ORA #$10 
bcs skipScroll

ldx #$27 ;Shift rows (first half)
shiftRows1
lda row+(1*40),x
sta row,x
lda row+(2*40),x
sta row+(1*40),x
lda row+(3*40),x
sta row+(2*40),x
lda row+(4*40),x
sta row+(3*40),x
lda row+(5*40),x
sta row+(4*40),x
lda row+(6*40),x
sta row+(5*40),x
lda row+(7*40),x
sta row+(6*40),x
lda row+(8*40),x
sta row+(7*40),x
lda row+(9*40),x
sta row+(8*40),x
lda row+(10*40),x
sta row+(9*40),x
lda row+(11*40),x
sta row+(10*40),x
lda row+(12*40),x
sta row+(11*40),x
dex
bpl shiftRows1

ldx #$27  ;Shift rows (second half)
shiftRows2
lda row+(13*40),x
sta row+(12*40),x
lda row+(14*40),x
sta row+(13*40),x
lda row+(15*40),x
sta row+(14*40),x
lda row+(16*40),x
sta row+(15*40),x
lda row+(17*40),x
sta row+(16*40),x
lda row+(18*40),x
sta row+(17*40),x
lda row+(19*40),x
sta row+(18*40),x
lda row+(20*40),x
sta row+(19*40),x
lda row+(21*40),x
sta row+(20*40),x
lda row+(22*40),x
sta row+(21*40),x
lda row+(23*40),x
sta row+(22*40),x
lda row+(24*40),x
sta row+(23*40),x
dex
bpl shiftRows2

;Now input message
ldx #$00
messRead
lda scrollText,x
cmp #$00
bne storeText 
lda #<scrollText
sta messRead+1
lda #>scrollText
sta messRead+2
jmp messRead
;Store the row of text from the scroll text
storeText
sta row+(24*40),x
inx 
cpx #$28
bne messRead

;Fetch next row of text from the scroll text
lda messRead+1
clc
adc #40 ;Read 40 chars for next row
sta messRead+1
;bcs exitUpScroll
lda messRead+2
adc #$00
sta messRead+2
exitUpScroll
rts

ydelay !byte 0
ypos !byte 0
rt !byte 0

;Our main scroll text message 

!ct scr
scrollText
!text "----------------------------------------"
!text "hello there,                            "
!text "what you can see here is an upward      "
!text "scrolling message, which consists of 1x1"
!text "characters.                             "
!text "                                        "
!text "this message can either be long or short"
!text "but you must make sure that the number  "
!text "of characters = 40 per text row         "
!text "otherwise you will get strange results  "
!text "                                        "
!text "okay, message resets ...                "
!byte 0
