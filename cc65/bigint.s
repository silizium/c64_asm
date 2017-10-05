;bigint.s
;for as65 assembler for cc65 package
;Version 0.1
;20071004 by H.Behrens
;mail: pebbles@schattenlauf.de
		.setcpu "6502X"
		.MACPACK generic
;		.import c64
		.import BSOUT
		.import _tistart,_tistop,_tistprint,_tiprint
		.import bcd2bin, hexout

;		BSOUT = $FFD2		
		pointer1=$fb						;$fb/$fc
		pointer2=$fd						;$fd/$fe
		tmppptr=$4b		;+$4c
		fac1=$61
		fac2=$69
		fac3=$57		;..5b
		fac4=$5c		;..60
		stack=$100
		
		accu=pointer1
		arg=accu+2


.macro	chout char
		lda #char
		jsr BSOUT
.endmacro

		.segment "STARTUP"

.macro  basicstart nr
		.org $0801
;Basic Start
		.word *
		.org *-2
		.word @lline
		.ifnblank nr
		   .word nr		; Zeilennummer
		.else
		   .word 0
		.endif
		.byte $9e		; SYS
		.asciiz .sprintf ("%d", *+7)
@lline: .word 0
.endmacro



		basicstart 2007

_main: 		lda #>fl2
		pha
		lda #<fl2
		pha
		jsr bigout
		chout 13
		lda #>fl1
		pha
		lda #<fl1
		pha
		jsr bigout
		chout 13
		lda #>fl3
		pha
		lda #<fl3
		pha
		jsr _tistart
		jsr bcdmul
		jsr _tistprint
		chout 13
		jsr bigout
		chout 13
		tsx
		txa
		axs #-6				;illegal opc x=a and x-#
		txs
		rts

;####################
;Bigint Subroutinen #
;####################
.proc bigout	;print bcd stack hi, lo
		tsx
		lda stack+3,x
		sta accu
		lda stack+4,x
		sta accu+1
		ldy #0
		lda (accu),y
		tax
		inx
L1:		iny				;skip zero start
		dex
		lda (accu),y
		beq L1				;skip zero end
L2:		lda (accu),y
		jsr bcdout
		iny
		dex
		bne L2
		rts
.endproc

.proc bcdout	;printbcd(a)
		pha
		lsr
		lsr
		lsr
		lsr
		add #'0'
		jsr BSOUT
		pla
		and #$0f
		add #'0'
		jsr BSOUT
		rts
.endproc

.proc clraccu
		ldy #0
		lda (accu),y
		tay
		lda #0
L1:		sta (accu),y
		dey
		bne L1
		rts
.endproc

.proc bigadd	;accu+=arg
		sei
		sed
		clc
		ldy #0
		lda (accu),y
		tay
L1:		lda (accu),y
		adc (arg),y
		sta (accu),y
		dey
		bne L1
		cld
		cli
		rts
.endproc

.proc bigsub	;accu-=arg
		sei
		sed
		sec
		ldy #0
		lda (accu),y
		tay
L1:		lda (accu),y
		sbc (arg),y
		sta (accu),y
		dey
		bne L1
		cld
		cli
		rts
.endproc

;Multipliziere  mit 10 (bcd)
.proc mulbig10	;stack(addr) <<4
		tsx
		lda stack+3,x
		sta accu
		lda stack+4,x
		sta accu+1
		ldx #4
L1:		ldy #0
		lda (accu),y
		tay
		clc
L2:		lda (accu),y
		rol
		sta (accu),y
		dey
		bne L2
		dex
		bne L1
		rts
.endproc

;Multipliziere Lownibble von Accu mit 10
.proc mula10	;a=a*10, Indizierung der Multiplikationstabelle
		asl		; x2
		pha		;push
		asl		; x4
		asl		; x8
		tsx
		add stack+1,x	;+ x2
		inx		;pop Stack wiederherstellen
		txs
		rts
.endproc

.proc bcdmulay	;a=a*y für Lownibble a und y Ergebnis lo+hinibble
		;"Kleines Einmaleins"
		pha		;push a
		tya		;y
		jsr mula10	;a=a*10
		tsx
		add stack+1,x
		tay
		inx
		txs		;pop
		lda bcdmultab,y
		rts
.endproc
		
;Kreuzmultiplikation, "Großes Einmaleins"
;Rückgabe in arg2hi, arg1lo
.proc mulbcd	;stack arg1.arg2=arg1 * arg2
	arg1	=stack+3	;stack+1 u. +2=jsr-Adresse
	arg2	=stack+4
	arglo1	=fac3+0
	arghi1	=fac3+1
	arglo2	=fac3+2
	arghi2	=fac3+3
	reslo	=fac3+4
	reshi	=fac3+5
	tmphi	=fac3+6
		tsx			;hole arg1 vom stack
		lda arg1,x
		lsr
		lsr
		lsr
		lsr
		sta arghi1		;und merken des Zehners
		lda arg2,x		;hole arg2 vom stack
		lsr
		lsr
		lsr
		lsr
		sta arghi2		;und merken des Zehners
		lda arg1,x		;arg1 vom stack
		and #$0f
		sta arglo1		;und merken des Einers
		lda arg2,x		;arg2 vom stack
		and #$0f
		sta arglo2		;und merken des Einers
		tay			;1x1  (0x * 0x)
		lda arglo1
		jsr bcdmulay
		sta reslo		;result low
		
		lda arghi1		;10x10 (x0 * x0)
		tay
		lda arghi2
		jsr bcdmulay
		sta reshi		;result hi
		
		lda #0
		sta tmphi		;zwischenergebnis hi löschen
		
		lda arglo1		;1x10  (x0 * 0x)
		tay
		lda arghi2
		jsr bcdmulay
		
		asl 			;hochshiften auf 0xx0
		rol tmphi
		asl
		rol tmphi
		asl 
		rol tmphi
		asl 
		rol tmphi
		sei
		sed
		add reslo
		sta reslo
		lda reshi
		adc #0
		sta reshi
		lda tmphi
		adc reshi
		sta reshi
		cld
		cli
		
		
		lda #0
		sta tmphi		;zwischenergebnis hi löschen
		
		lda arglo2		;10x1  (0x * x0)
		tay
		lda arghi1
		jsr bcdmulay
		
		asl 			;hochshiften auf 0xx0
		rol tmphi
		asl
		rol tmphi
		asl 
		rol tmphi
		asl 
		rol tmphi
		sei
		sed
		add reslo
		sta reslo
		lda reshi
		adc #0
		sta reshi
		lda tmphi
		adc reshi
		sta reshi
		cld
		cli
		
		tsx			;Ergebnis speichern
		lda reshi
		sta arg1,x
		lda reslo
		sta arg2,x
		
		rts
.endproc


.proc bcdaddwordy	;stack+4=lo stack+3=hi, y=position(accu)
	arglo	=stack+4
	arghi	=stack+3
		tsx
		sei
		sed			;Decimal bcd
		lda arglo,x		;add lo
		add (accu),y
		sta (accu),y
		dey
		beq end1
		lda arghi,x		;add hi+C
		adc (accu),y
		sta (accu),y
L1:		dey			;Überträge addieren
		beq end1
		bcc end1
		lda #0
		adc (accu),y
		sta (accu),y
		bcs L1
end1:		cld
		cli
		rts
.endproc

.proc bcdmul
	reslo	=stack+3
	reshi	=stack+4
	arg2lo	=stack+5
	arg2hi	=stack+6
	arg1lo	=stack+7
	arg1hi	=stack+8
	fac1lo	=fac1+0
	fac1hi	=fac1+1
	fac2lo	=fac1+2
	fac2hi	=fac1+3
		tsx
		lda reslo,x
		sta accu
		lda reshi,x
		sta accu+1
		lda arg1lo,x
		sta fac1lo
		lda arg1hi,x
		sta fac1hi
		lda arg2lo,x
		sta fac2lo
		lda arg2hi,x
		sta fac2hi
		jsr clraccu
		
		
		tsx				;Stackplatz temporäre Vars
		txa
		axs #4				;illegal opc x:=a and x-#
		;dex
		;dex
		;dex
		;dex
		txs
		
		ldy #0
		lda (fac2lo),y
		sta stack+4,x			;zähler speichern
		lda (fac1lo),y
		sta stack+3,x			;zähler speichern
		
L1:		lda stack+3,x
		tay
		lda (fac1lo),y
		sta stack+1,x
		
		lda stack+4,x
		tay
		lda (fac2lo),y
		sta stack+2,x
		
		jsr mulbcd
		tsx
		lda stack+4,x
		add stack+3,x
		tay 
		jsr bcdaddwordy
		tsx
		dec stack+3,x
		bne L1
		ldy #0
		lda (fac1lo),y
		sta stack+3,x
		dec stack+4,x
		bne L1
		
		txa
		axs #-4			;x+=4 -(-4)
		txs
		rts
.endproc

;Data Secion
;		.pushseg
;		.data
;Multiplikationstabelle "Einmaleins"
bcdmultab: 	.repeat 10, J
		.repeat 10, I
		.byte ((I*J)/10)*16+(I*J) .mod 10
		.endrep		
		.endrep
;Bigint Variablen		
fl1:		.byte 8, 0,0,$03,$75, $12, $34, $56, $78
fl2:		.byte 8, 0,0,$89,$00, $99, $99, $99, $99
fl3:		.byte 16
		.repeat 16
		.byte 0
		.endrep
;		.popseg