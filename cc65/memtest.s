;memtest64
;Tests for memory errors on a C=64, that occur on older models
;Cause these errors are mostly due to current instability
;the routine does not give a damn to the specific location
;and just counts the biterrors
;
;load"memtest",8:run
;compile: ca65 -t c64 memtest.s && ld65 -t c64 -o memtest memtest.o c64.lib
;with cc65 compiler/assembler package
;
;© 2007 Hanno Behrens (pebbles@schattenlauf.de)
;for http://www.forum64.de/wbb2/thread.php?threadid=900&page=4
	.setcpu "6502X"
	.macpack generic
	.macpack cbm
	.import SETLFS,SETNAM,OPEN,CLOSE,ERROR,GET
	.import BASIN,BSOUT,CHKIN,CKOUT,CLRCH,READST

	.segment "STARTUP"
	
	.define VERSION "v1.4"
	STACK=$100
	SCREEN=$0400
	ST=$90
	k_scrout=$e716
	pointer=$fb		;+fc
	uintout=$bdcd		;Basic Positive Integerzahl ausgeben (a/x)
	checkstop=$ffe1		;$f6ed Stop-Taste abfragen eq->stop
	basic_nmi_vec	= $a002			;Basic NMI-Vector
	
	; Direct entries
CLRSCR 	       	:= $E544
KBDREAD	       	:= $E5B4
NMIEXIT         := $FEBC
; ---------------------------------------------------------------------------
; Processor Port at $01
PP		= $01

LORAM		= $01  		; Enable the basic rom
HIRAM		= $02  		; Enable the kernal rom
IOEN 		= $04  		; Enable I/O
CASSDATA	= $08  		; Cassette data
CASSPLAY	= $10  		; Cassette: Play
CASSMOT		= $20  		; Cassette motor on
TP_FAST		= $80  		; Switch Rossmoeller TurboProcess to fast mode

RAMONLY		= $F8  		; (~(LORAM | HIRAM | IOEN)) & $FF

.macro  basicstart nr
		.org $0801
;Basic Start
		.word *
		.org *-2
		.word :+
		.ifnblank nr
		   .word nr		; Zeilennummer
		.else
		   .word 0
		.endif
		.byte $9e		; SYS
		.asciiz .sprintf ("%d", *+7)
:		.word 0
.endmacro



		basicstart 2007

_memtest:	
		jsr initscr
repeat:		lda #$00
		jsr fillmem
		jsr cmpmem
		jsr result

		lda #$ff
		jsr fillmem
		jsr cmpmem
		jsr result

		lda #$55
		jsr fillmem
		jsr cmpmem
		jsr result

		lda #$aa
		jsr fillmem
		jsr cmpmem
		jsr result

		lda #$5a
		jsr fillmem
		jsr cmpmem
		jsr result

		lda #$a5
		jsr fillmem
		jsr cmpmem
		jsr result

		lda #$0f
		jsr fillmem
		jsr cmpmem
		jsr result

		lda #$f0
		jsr fillmem
		jsr cmpmem
		jsr result


		jmp repeat


.proc initscr
		jsr CLRSCR
		lda #13
		jsr BSOUT
		lda #$00
		tax
		tay
		sta testrun		;Zähler löschen
		sta testrun+1
		sta testrun+2
		sta testrun+3
		jsr printstatus
		rts
.endproc

testrun:		.byte 0,0,0,0
.proc result
		pha
		txa
		pha
		tya
		pha
		jsr checkstop
		bne nostop
		pla
		pla
		pla
		jmp (basic_nmi_vec)
nostop:		sei
		sed
		lda #1
		add testrun+3
		sta testrun+3
		lda testrun+2
		adc #0
		sta testrun+2
		lda testrun+1
		adc #0
		sta testrun+1
		lda testrun
		adc #0
		sta testrun
		cld
		cli
		pla
		tay
		pla
		tax
		pla
		cmp #0
		bne fehler
		cpx #0
		bne fehler
		tya			;membyte 00 ff 55 aa 37
		jmp printstatus
		
fehler:		pha
		txa
		pha
		ldy #0
loop:		lda rtext,y
		beq :+
		jsr BSOUT
		iny
		bne loop
:		pla
		tax
		pla
		jsr uintout
		rts
rtext:		.byte 13
		.asciiz "fehlerbits: "
.endproc

.proc printstatus
		pha
		ldy #0
		ldx #0
:		lda statustext,x
		beq :+
		jsr txt2scr
		bne :-
:		txa
		axs #7
		pla
		jsr hex2scr
		ldy #0
		txa
		axs #-6
		lda testrun
		jsr bcd2scr
		lda testrun+1
		jsr bcd2scr
		lda testrun+2
		jsr bcd2scr
		lda testrun+3
		jsr bcd2scr
		rts
		
statustext:	scrcode "memtest ",VERSION," check byte     run",0
.endproc

.proc bcd2scr
		pha
		pha
		pha
		jsr scrptr_y
		pla
		sta adr1+1
		sta adr2+1
		pla 
		sta adr1+2
		sta adr2+2
		pla
		pha
		lsr
		lsr
		lsr
		lsr
		add #'0'
adr1:		sta SCREEN,x
		inx
		pla
		and #$0f
		adc #'0'
adr2:		sta SCREEN,x
		inx
		rts
.endproc

.proc hex2scr	;a=hexbyte x=xcoord y=ycoord 0..39/24
		pha
		pha		;platz für scrptr adresse hi
		pha		;lo
		jsr scrptr_y
		pla
		sta adr1+1
		sta adr2+1
		pla
		sta adr1+2
		sta adr2+2
		pla
		pha
		lsr a
		lsr a
		lsr a
		lsr a
		tay
		lda hexcode,y
adr1:		sta SCREEN,x
		inx
		iny
		pla
		and #$0f
		tay
		lda hexcode,y
adr2:		sta SCREEN,x
		inx
		rts
hexcode:	scrcode "0123456789abcdef"
.endproc

.proc txt2scr	;a=screencode, x, y
		pha
		pha
		pha
		jsr scrptr_y
		pla
		sta adr+1
		pla
		sta adr+2
		pla
adr:		sta SCREEN,x
		inx
		rts
.endproc

.proc scrptr_y	;y=ycoord, Rückgabe: stack (PTR)
	tabLSBscr=$ecf0
	tabMSBscr=$d9
	hiByteVid=$0288

		pha
		txa
		pha
		tsx
		lda tabLSBscr,y
		sta STACK+5,x
		lda tabMSBscr,y
		and #$03
		ora hiByteVid
		sta STACK+6,x
		pla
		tax
		pla
		rts
.endproc

.proc fillmem				;A=Speicherwert füllt $1000-$ffff
		jsr ramon
		ldy #>speicher+1	;$10
		sty pointer+1
		ldy #$00
		sty pointer
loop:		sta (pointer),y
		iny
		bne loop
		inc pointer+1
		bne loop
		jsr ramoff
		rts 
.endproc

.proc cmpmem	
		sta loop+1		;A=Speicherwert vergleicht $1000-$ffff, Rückgabe A
		sta cnt+5
		jsr ramon
		ldy #>speicher+1	;$10
		sty pointer+1
		ldy #$00
		sty pointer
		sty cnt+1		;Rückgabewert resetten
		sty cnt+3
loop:		lda #$00		;wird überschrieben
		eor (pointer),y
		beq ok
		jsr bitcount
		add cnt+1
		sta cnt+1
		bcc ok
		inc cnt+3
ok:		iny
		bne loop
		inc pointer+1
		bne loop
		jsr ramoff
cnt:		ldx #$00		;bitcount-Rückgabe lo
		lda #$00		;hi
		ldy #$00		;Vergleichswert
		rts 
.endproc

.proc bitcount
  BitCountSeven:
         lsr                     ; put bit 0 into carry, bit 7-1 in bit 6-0 and value 0 in bit 7 
         tax 
         lda SevenBitCounts,x    ; Fetch the bit count 
         adc #0                  ; add in bit 0 
	 rts
 ; Look up table of bit counts in the values $00-$7F 
 
 SevenBitCounts: 
         .byte 0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4 
         .byte 1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5 
         .byte 1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5 
         .byte 2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6 
         .byte 1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5 
         .byte 2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6 
         .byte 2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6 
         .byte 3,4,4,5,4,5,5,6,4,5,5,6,5,6,6,7 
.endproc


.proc ramon	
		pha			;Accu sichern
		sei
		lda PP
		and #RAMONLY
		sta PP
		pla
		rts
.endproc

.proc ramoff	
		pha			;Accu sichern
		lda PP
		ora #(HIRAM|LORAM|IOEN)
		sta PP
		cli
		pla
		rts
.endproc

speicher:	
