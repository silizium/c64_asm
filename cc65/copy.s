;minicompo
;copy file 8->9
;Erste Bildschirmzeile Filename eingeben Beispiel "copy.s,w,p"
;dann sys4096
;Ergebnis: Kopie von copy.s von #8 nach #9
;©2007 Hanno Behrens (pebbles@schattenlauf.de) 
;http://www.forum64.de/wbb2/thread.php?threadid=13900
	.setcpu "6502X"
	.macpack generic
	.import SETLFS,SETNAM,OPEN,CLOSE,ERROR,GET
	.import BASIN,BSOUT,CHKIN,CKOUT,CLRCH,READST

	.segment "STARTUP"

	SCREEN=$0400
	ST=$90
	k_scrout=$e716

	.org $1000
		.word *
		.org *-2
.proc filecopy
		ldy #21
		ldx #0
wandel:		lda SCREEN,y
		and #$3f
		cmp #$20		;space
		bcs notext
		cpx #0
		bne noset
		pha			;init x=strlen-1
		tya
		tax
		pla
noset:		ora #$40
notext:		sta SCREEN,y
		dey
		bpl wandel
		inx			;strlen=position+1
		txa			;strlen merken
		pha
		sub #4
		ldy #1
		ldx #8
		jsr open		;a=strlen, x=drive, y=kanal
		;bcs error
		pla			;strlen wiederholen
		ldy #2
		ldx #9
		jsr open		;a=strlen, x=drive, y=kanal
		;bcs error2
loop:		ldx #1
		jsr CHKIN
		jsr BASIN
		ldy ST		;64=EOF
		bne endloop
		pha
		ldx #2
		jsr CKOUT
		pla
		jsr BSOUT
		ldy ST
		beq loop		;bcc loop
endloop:	jsr CLRCH
error3:		lda #2
		jsr CLOSE
error2:		lda #1
		jsr CLOSE
error:		rts

open:		pha		;a=strlen, x=drive, y=kanal
		tya
		ldy #2
		jsr SETLFS

		pla			
		ldx #<SCREEN
		ldy #>SCREEN
		jsr SETNAM		
		jsr OPEN
		rts
.endproc
