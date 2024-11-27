.include "time.inc"

.export _rtc_start
.export _rtc_read
.export _rtc_screen
.export _rtc_secs
.export _rtc_test

TIHIG	= $a0		; 24 bit time in Jiffies hi endian
TIMED	= $a1
TILOW	= $a2

.proc _rtc_start: near
	ldx #$0a    ; control register A
	lda #$20    ; %x010xxxx
	stx $de00
	sta $de01
	rts
.endproc

.proc _rtc_secs: near
; this one reads the current second
	lda #$00	; register 0 - seconds
	sta $de00	; address register
	lda $de01	; data register
	rts
.endproc

.proc _rtc_screen: near
	ldx #0
@loop:	stx $de00
	lda $de01
	sta $0400,x
	inx
	cpx #$80
	bne @loop
	rts
.endproc

.proc _rtc_read: near
	ldx #0
@loop:	stx $de00
	lda $de01
	sta $0400,x
	inx
	cpx #$80
	bne @loop
	rts
.endproc


.proc _rtc_test: near
LETTI	= $a9e0
TXTPTR	= $7a
CHRGOT	= $79
	;sty length
	;sta dollar
	lda TXTPTR	;preserve these
	pha
	lda TXTPTR+1
	pha
	lda #<variable
	sta TXTPTR	;point to our desired variable
	lda #>variable
	sta TXTPTR+1
	jsr $b08b		;get location of string
	sta $49
	sty $4a		;forgot why important (that's what my source code says!)
	lda #<strptr
	sta $64
	lda #>strptr	;pointing to our string descriptor now
	sta $65
	jsr LETTI		;$aa52 ;and assign the string!
	pla
	sta TXTPTR+1	;put these back
	pla
	sta TXTPTR
	rts
variable:	.asciiz	"ti$"
strptr:	.byte	6
	.word	time
time:	.asciiz	"123456"
.endproc

;multipliziere 8 mal 8 bit
;
; md Multiplikant bleibt erhalten
; mr Multiplikator wird überschrieben
; das 16-Bit Produkt steht in:
; mr - Highbyte und
; a  - Lowbyte
.include "mul8.asm"



;(C:$c006) d c000 c010
;.C:c000  A9 06       LDA #$06
;.C:c002  A0 C0       LDY #$C0
;.C:c004  A2 11       LDX #$11
;.C:c006  86 22       STX $22
;.C:c008  84 23       STY $23
;.C:c00a  20 9E AD    JSR $AD9E
;.C:c00d  20 A3 B6    JSR $B6A3
;.C:c010  60          RTS
;>C:c011  74 69 24 3d  22 31 32 33   TI$="123
;>C:c019  34 35 36 22  00 00 00 00   456"

