/*microtracker v1.0 by the Syndrom/TIA/Crest*/

.pc =$0801 "Basic Upstart Program"
.var startup=$0900

:BasicUpstart(startup)

//----------------------------------------------------------
//----------------------------------------------------------
//					Simple IRQ
//----------------------------------------------------------
//----------------------------------------------------------
.pc = startup "Main Program"

			lda #$00
			sta $d020
			sta $d021
			lda #$00
			jsr musicinit	// init music
			jsr $e544
			sei
			lda #<irq1
			sta $0314
			lda #>irq1
			sta $0315
			asl $d019
			lda #$7b
			sta $dc0d
			lda #$81
			sta $d01a
			lda #$1b
			sta $d011
			lda #$80
			sta $d012
			cli
this:	jmp this
//----------------------------------------------------------
irq1:  	
			asl $d019
			:SetBorderColor(2)
			lda $d012
			sta timer
			jsr musicplay // play music
			lda $d012
			sec
			sbc timer
			clc
			adc #$30
			cmp $0400
			bcc notbigger
			sta $0400			
notbigger:		:SetBorderColor(0)			
			pla
			tay
			pla
			tax
			pla
			rti

timer: .byte $00

.macro SetBorderColor(color) {
	lda #color
	sta $d020
}




.pc = $1000
musicinit:	jmp init
musicplay:	jmp play

.var hardrestartcounter=3

hardrestartindex:		//value to put into wave in hardrestartframes (from right to left)
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

.text "player and music by the syndrom!"


//zeropage-variables
//uses $30-$47 by default - if you have to split, insert new calculation inbetween (i=$xx)


.var i =$30 
.var voice1pointer=i 
.var voice2pointer=[i=i+2] 
.var voice3pointer=[i=i+2] 
.var sound1pointer=[i=i+2] 
.var sound2pointer=[i=i+2] 
.var sound3pointer=[i=i+2] 
.var duration1=[i=i+2] 
.var duration2=[i=i+1] 
.var duration3=[i=i+1] 
.var sound1index=[i=i+1] 
.var note3=[i=i+1] 
.var sound2index=[i=i+1] 
.var note2=[i=i+1] 
.var sound3index=[i=i+1] 
.var pulsecontrol=[i=i+1] 
.var vibratopointer=[i=i+1] 
.var vibratoindex=[i=i+2] 




init:		ldy #$18		//clear the sid
		lda #$00
loop1:		sta $d400,y
		dey
		bpl loop1
		ldy #$0e
		ldx #$02
loop2:		lda pulseinit,x		//pulsehigh ???
		sta $d403,y
		lda waveinit,x
		sta $d404,y		//wave
		lda #$00
		sta $d405,y		//attack
		lda #$01
		sta duration1,x
		lda voiceinit,x
		sta voice1pointer,x
		lda voiceinit+3,x
		sta voice1pointer+3,x
		lda sidvalues,x
		sta $d416,x
		tya
		sec
		sbc #$07
		tay
		dex
		bpl loop2
		rts
pulseinit:					//?
.byte $08,$03,$03
waveinit:
.byte $08,$08,$08
voiceinit:
.word voice1
.word voice2
.word voice3
voiceloop:
.word voice1loop
.word voice2loop
.word voice3loop

sidvalues:
.byte $00,$f4,$1f

play:		ldx #$00
		dec duration1
		beq branch1
		lda duration1
		cmp #hardrestartcounter
		bcs branch2
		stx $d405
		stx $d406
		stx $d404
		jmp branch1109
		
branch1:	ldy #$00			//voice1
		lda (voice1pointer),y
		sta sound1pointer
		iny
		lda (voice1pointer),y
		beq restartmusic
		sta sound1pointer+1
		iny
		lda (voice1pointer),y
		sta duration1
		lda voice1pointer
		clc
		adc #$03
		sta voice1pointer
		lda voice1pointer+1
		adc #$00
		sta voice1pointer+1
		ldy #$00
		lda (sound1pointer),y
		sta $d406
		sty $d405
		iny
		sty $d404
		sty sound1index
		jmp branch1109

restartmusic:	ldx #$02
loop3:		lda voiceloop,x
		sta voice1pointer,x
		lda voiceloop+3,x
		sta voice1pointer+3,x
		lda #$01
		sta duration1,x
		dex
		bpl loop3
		lda #$08
		sta $d404
		sta $d40b
		sta $d412
		rts

branch2:/*10f7*/ldy sound1index
		lda (sound1pointer),y
		beq branch1109
		sta $d401
		iny
		lda (sound1pointer),y
		sta $d404
		iny
		sty sound1index
branch1109:	dec duration3		//voice3
		beq branch111c
		lda duration3
		cmp #hardrestartcounter
		bcs branch1151
		stx $d405
		stx $d406
		stx $d404
		jmp branch1185
branch111c:	ldy #$00		
		lda (voice3pointer),y
		sta sound3pointer
		iny
		lda (voice3pointer),y
		sta sound3pointer+1
		iny
		lda (voice3pointer),y
		sta duration3
		iny
		lda (voice3pointer),y
		sta note3
		lda voice3pointer
		clc
		adc #$04
		sta voice3pointer
		lda voice3pointer+1
		adc #$00
		sta voice3pointer+1
		ldy #$00
		lda (sound3pointer),y
		sta $d414		//sr
		sty $d413		//ad
		iny
		sty $d412		//wave
		sty sound3index
		jmp branch1185

branch1151:	ldy sound3index
		lda (sound3pointer),y
		beq branch115e
		cmp #$ff
		bne branch1166
		jmp branch1185
branch115e:	iny
		lda (sound3pointer),y
		sta sound3index
		tay
		lda (sound3pointer),y
branch1166:	sta $d416		//filter
		iny
		lda (sound3pointer),y
		sta $d412		//wave
		iny
		lda (sound3pointer),y
		iny
		sty sound3index
		clc
		adc note3
		tay
		lda freqhi,y
		sta $d40f
		lda freqlo,y
		sta $d40e
branch1185:	dec duration2			//voice2
		beq branch1196
		lda duration2
		cmp #hardrestartcounter
		bcs branch11da
		stx $d405
		stx $d406
		stx $d404
		rts
branch1196:	ldy #$00	
		lda (voice2pointer),y
		sta sound2pointer
		iny
		lda (voice2pointer),y
		sta sound2pointer+1
		iny
		lda (voice2pointer),y
		sta duration2
		iny
		lda (voice2pointer),y
		sta note2
		lda voice2pointer
		clc
		adc #$04
		sta voice2pointer
		lda voice2pointer+1
		adc #$00
		sta voice2pointer+1
		ldy #$00
		sty vibratoindex
		lda (sound2pointer),y
		sta $d40d		//sr
		sty $d40c		//ad
		iny
		sty $d40b		//wave
		lda (sound2pointer),y
		sta pulsecontrol
		iny
		lda (sound2pointer),y
		sta vibratopointer
		iny
		lda (sound2pointer),y
		sta vibratopointer+1
		iny
		sty sound2index
		rts
branch11da:	ldy sound2index
		lda (sound2pointer),y
		beq branch11e5
		cmp #$ff
		bne branch11ed
		rts
branch11e5:	iny
		lda(sound2pointer),y
		sta sound2index
		tay
		lda (sound2pointer),y


branch11ed:	sta $d40b		//wave
		lda pulsecontrol
		beq branch1200
		iny
		lda (sound2pointer),y
		sta $d409		//pulselow
		iny
		lda (sound2pointer),y
		sta $d40a		//pulsehigh
branch1200:	iny
		lda (sound2pointer),y
		iny
		sty sound2index
		clc
		adc note2
		tax
		lda freqlo,x
		ldy vibratoindex
		iny
		clc
		adc (vibratopointer),y
		sta $d407
		dey
		lda freqhi,x
		adc (vibratopointer),y
		sta $d408
		iny
		iny
		lda (vibratopointer),y
		cmp #$80
		beq branch122a
		sty vibratoindex
		rts
branch122a:	iny
		lda (vibratopointer),y
		sta vibratoindex
		rts
branch1230:	sta $d407		//obsolete ?
		lda freqhi,x
		sta $d408
		rts





freqlo:
.byte 	$0c,$1c,$2d,$3e,$47,$66,$7b,$91
.byte	$a9,$c3,$dd,$fa,$18,$38,$5a,$7d
.byte	$a3,$cc,$f6,$23,$53,$86,$bb,$f4
.byte	$30,$70,$b4,$fb,$47,$98,$ed,$47
.byte	$a7,$0c,$77,$e9,$61,$e1,$68,$f7
.byte	$8f,$30,$da,$8f,$4e,$18,$ef,$d2
.byte	$c3,$c3,$d1,$ef,$1f,$60,$b5,$1e
.byte	$9c,$31,$df,$a5,$87,$86,$a2,$df
.byte	$3e,$c1,$6b,$3c,$39,$63,$be,$4b
.byte	$0f,$0c,$45,$bf,$7d,$83,$d6,$79
.byte	$73,$c7,$7c,$97,$1e,$18,$8b,$7e
.byte	$fa,$06,$ac,$f3,$e6,$8f,$f8,$fc

freqhi:
.byte	$01,$01,$01,$01,$01,$01,$01,$01
.byte	$01,$01,$01,$01,$02,$02,$02,$02
.byte	$02,$02,$02,$03,$03,$03,$03,$03
.byte	$04,$04,$04,$04,$05,$05,$05,$06
.byte	$06,$07,$07,$07,$08,$08,$09,$09
.byte	$0a,$0b,$0b,$0c,$0d,$0e,$0e,$0f
.byte	$10,$11,$12,$13,$15,$16,$17,$19
.byte	$1a,$1c,$1d,$1f,$21,$23,$25,$27
.byte	$2a,$2c,$2f,$32,$35,$38,$3b,$3f
.byte	$43,$47,$4b,$4f,$54,$59,$5e,$64
.byte	$6a,$70,$77,$7e,$86,$8e,$96,$9f
.byte	$a8,$b3,$bd,$c8,$d4,$e1,$ee,$fd

//------------------------------------------------------------
//sounddata
//format voice1 (Drumtrack):
//.byte SR Value
//.byte Freqhi,wave
//.byte Freqhi,wave - if freqhi=0 -> end of sound

basedrum:					//basedrum
.byte $f7,$dd,$81,$0c,$11,$0a,$11,$08,$11,$06,$10,$03,$10,$00	

snare:
.byte $f9,$fc,$81,$0e,$41,$5c,$81,$0d,$40,$80,$3c,$0a,$40,$3b,$80,$00

hihat:
.byte $84,$fe,$81,$d0,$80,$a0,$80,$00


//------------------------------------------------------------
//format voice2 (vibratotrack):
//first frame
//.byte SR Value
//.byte pulsecontrol    =$0 -> pulse off, other -> pulse on
//.word vibratooffset
//following frames
//.byte wave		=$0 -> next byte is loopindex, =$FF -> end
//.byte noteoffset
//if pulse = on
//.byte wave,pulselow,pulsehigh,noteoffset

silence02:					//silence
.byte $00,$00 .word novibrato
.byte $08,$00,$ff


chord:
.byte $6a,$01 .word novibrato
.byte $41,$00,$04,$00
.byte $41,$20,$04,$00
.byte $40,$40,$04,$00
.byte $40,$60,$04,$07
.byte $40,$80,$04,$07
.byte $40,$60,$04,$07
.byte $40,$40,$04,$0c
.byte $40,$20,$04,$0c
.byte $40,$00,$04,$0c
.byte $40,$00,$04,$00
.byte $40,$20,$04,$00
.byte $00,$0c

chord1:
.byte $6a,$01 .word novibrato
.byte $41,$00,$04,$00
.byte $41,$20,$04,$00
.byte $40,$40,$04,$00
.byte $40,$60,$04,$07
.byte $40,$80,$04,$07
.byte $40,$60,$04,$07
.byte $40,$40,$04,$0a
.byte $40,$20,$04,$0a
.byte $40,$00,$04,$0a
.byte $40,$00,$04,$00
.byte $40,$20,$04,$00
.byte $00,$0c

chord2:
.byte $6a,$01 .word novibrato
.byte $41,$00,$04,$02
.byte $41,$20,$04,$02
.byte $40,$40,$04,$02
.byte $40,$60,$04,$07
.byte $40,$80,$04,$07
.byte $40,$60,$04,$07
.byte $40,$40,$04,$0e
.byte $40,$20,$04,$0e
.byte $40,$00,$04,$0e
.byte $40,$00,$04,$02
.byte $40,$20,$04,$02
.byte $00,$0c




//------------------------------------------------------------
//format voice3 (filtertrack):
//first frame
//.byte SR Value
//following frames
//.byte Filterhigh,wave,noteoffset
//note: if filterhigh=$00, next byte is loopindex. if filterhigh=$ff ->end

silence03:					//silence
.byte $00
.byte $fe,$08,$00
.byte $ff

filterbass:
.byte $b9
.byte $f0,$41,$00
.byte $a0,$41,$00
.byte $50,$41,$00
.byte $20,$41,$00
.byte $18,$41,$01
.byte $14,$41,$00
.byte $10,$41,$00
.byte $0c,$40,$ff
.byte $08,$40,$00
.byte $ff




//------------------------------------------------------------
//vibratotable
//.byte addvalue-high,addvalue-low	if highbyte=$80 -> next byte=loopindex

novibrato:			//empty
.byte $00,$00,$80,$00



//------------------------------------------------------------
//musicdata

voice1:
voice1loop:

//format .word soundoffset, .byte duration   if soundoffset=0000 then loop


//simple rythm
//-------------
.word basedrum .byte $0c
.word hihat .byte $06
.word hihat .byte $06
.word snare .byte $0c
.word hihat .byte $06
.word hihat .byte $06

//simple rythm
//-------------
.word basedrum .byte $0c
.word hihat .byte $06
.word hihat .byte $06
.word snare .byte $0c
.word hihat .byte $06
.word hihat .byte $06

//simple rythm
//-------------
.word basedrum .byte $0c
.word hihat .byte $06
.word hihat .byte $06
.word snare .byte $0c
.word hihat .byte $06
.word hihat .byte $06

//simple rythm+doublesnare
//-------------
.word basedrum .byte $0c
.word hihat .byte $06
.word hihat .byte $06
.word snare .byte $06
.word snare .byte $06
.word hihat .byte $06
.word snare .byte $06


.word $0000
//------------------------------------------------------------
voice2:
voice2loop:

//format .word soundoffset, .byte duration,note


.word silence02 .byte $0c,$00
.word chord 	.byte $24,$34

.word chord1 	.byte $30,$34

.word silence02 .byte $0c,$00
.word chord 	.byte $24,$2d

.word chord2 	.byte $30,$2d


//------------------------------------------------------------
voice3:
voice3loop:

//format .word soundoffset, .byte duration,note

.word filterbass .byte $12,$1c
.word filterbass .byte $12,$1c
.word filterbass .byte $0c,$1a

.word filterbass .byte $12,$17
.word silence03	 .byte $1e,$00

.word filterbass .byte $12,$15
.word filterbass .byte $12,$15
.word filterbass .byte $0c,$17

.word filterbass .byte $12,$10
.word silence03	 .byte $1e,$00
