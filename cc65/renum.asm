; written by paul baxter
; 2024 Hanno Behrens DL7HH
; cl65 -o renum renum.asm --start-addr 0xc000 -C c64-asm.cfg 
	.org $c000
;
;************
;*			 *
;* symbols  *
;*			 *
;************
;
chrout	= $ffd2
plot	= $fff0
bstart	= $2b ; start of basic
txtoff	= $04; offset text
lnoff	= $02 ; offset line number
nxoff	= $00 ; offset next address
;
; zero page usage
;
nxtln	= $fc ; ptr next statement
lnum	= $fe  ; next line num to use
incr	= $a3  ; line num increment
bnvar	= $4e ; num to convert to bcd
bcdstr	= $57; bcd string result
bcd	= $5c
;
; basic tokens
;
goto	= $89
gosub	= $8d
then	= $a7
quote	= $22
;
;************
;*			 *
;* storw  *
;*			 *
;************
;
.macro storw ad, num
	lda #<num
	sta ad
	lda #>num
	sta ad+1
.endmacro
;
;************
;*			 *
;*  movew  *
;*			 *
;************
;
.macro movew src, dst
	lda src
	sta dst
	lda src+1
	sta dst+1
.endmacro
;
;************
;*			 *
;*	addw  *
;*			 *
;************
;
.macro addw ad1, ad2, dst
	clc
	lda ad1
	adc ad2
	sta dst
	lda ad1+1
	adc ad2+1
	sta dst+1
.endmacro
;
;************
;*			 *
;* stzpiyw *
;*			 *
;************
;
.macro stzpiyw zp, yval, ad
	ldy #yval
	lda ad
	sta (zp),y
	lda ad+1
	iny
	sta (zp),y
.endmacro
;
;************
;*			 *
;* ldzpiyw *
;*			 *
;************
;
.macro ldzpiyw zp, yval
	ldy #yval
	lda (zp),y
	tax
	iny
	lda (zp),y
.endmacro 
;
;************
;*			 *
;* shft3byt *
;*			 *
;************
;
.macro shft3byt src, dst
	asl src+0
	rol src+1
	lda dst+0
	adc dst+0
	sta dst+0
	lda dst+1
	adc dst+1
	sta dst+1
	lda dst+2
	adc dst+2
	sta dst+2
.endmacro
;
;************
;*			 *
;* bcd2str  *
;*			 *
;************
;
.macro bcd2str src, dst
	lda src
	and $f0
	lsr
	lsr
	lsr
	lsr
	ora #$30
	sta dst
	lda src
	and #$0f
	ora #$30
	sta dst+1
.endmacro
;
;************
;*			 *
;* start	 *
;*			 *
;************
;
; init start of basic program
;
	movew bstart,nxtln
;
; init line number
	storw lnum,100
;
; init line number increment
	storw incr,10
;
; get the text of the line
nextln:	ldy #nxoff
	lda (nxtln),y
	bne prln
	iny
	lda (nxtln),y
	beq getln
prln:	sec
	jsr plot
	ldy #01
	clc
	jsr plot
	jsr prntline
;
getln:	ldy #txtoff -1
	ldx #00
nxtch:	iny
	lda (nxtln),y
	beq stln
;
; check for quote
chkquote:	cmp #quote
	bne chktok
	cpx #00
	bne inquote
	ldx #01
	bne nxtch
;
inquote:	ldx #00
	beq nxtch
	bne chktok ; never should get here? remove
;
;************
;*			 *
;* brannex  *
;*			 *
;************
; branch island
brannex:	bne nextln
	beq nextln
;
; search for goto gosub then
chktok:	cmp #goto
	bne chkgosub
findline:	clc
	bcc nxtch
;
chkgosub:	cmp #gosub
	beq findline
	cmp #then
	beq findline
	bne nxtch
;
; set nw basic line number
stln:	stzpiyw nxtln,lnoff,lnum
	lda #' '
	jsr chrout
	lda #'='
	jsr chrout
	lda #'>'
	jsr chrout
	jsr prntline
;
; incrment line number
	addw lnum,incr,lnum
;
; get pointer to next basic line
	ldzpiyw nxtln,nxoff
;
; save pointer to next line
	stx nxtln
	sta nxtln+1
;
; check for end of program
	cpx #00
	bne brannex
	cmp #00
	bne brannex
	rts
;
;************
;*			 *
;* prntline *
;*			 *
;************
;
prntline:	lda #lnoff ; can be removed
	ldy #lnoff
	lda (nxtln),y
	sta bnvar
	iny
	lda (nxtln),y
	sta bnvar+1
	jsr binbcd16
	ldy #00
pbcd:	lda bcdstr,y
	jsr chrout
	iny
	cpy #05
	bne pbcd
	rts
;
;************
;*			 *
;* binbcd16 *
;*			 *
;************
;
binbcd16:	sed
	lda #00
	sta bcd+0
	sta bcd+1
	sta bcd+2
	ldy #16
cnvbit:	shft3byt bnvar,bcd
	dey
	bne cnvbit
	cld
	bcd2str bcd+0,bcdstr+3
	bcd2str bcd+1,bcdstr+1
	lda bcd+2
	and #$0f
	ora #$30
	sta bcdstr+0
	rts
.end
