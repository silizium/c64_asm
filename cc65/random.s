;Random generators
;
;compile: ca65 -t c64 random.s && ld65 -t c64 -o random random.o c64.lib
;with cc65 compiler/assembler package
;
;© 2007 Hanno Behrens (pebbles@schattenlauf.de)
;LGPL Licence
		.setcpu "6502X"
		.macpack generic
		.macpack cbm
		.include "c64io.inc"
		
		.segment "STARTUP"
		
		.org $9000
		.word *
		.org *-2

STACK		=$100

;combination of generator 65535 and 32767 has periode of 2147385345
;result in a (lo) and y (hi)

.proc statistic
	datalo=$8e00
	datahi=$8f00
	RUNS=100-1
		jsr sidinit
		ldy #0
		tya
clear:		sta datalo,y
		sta datahi,y
		dey
		bne clear
		
		lda #>RUNS
		pha
		lda #<RUNS
		pha
l1:		ldx #0
l2:		jsr crc16rand
		;lda SID+Sid::noise
		tay
		lda datalo,y
		add #1
		sta datalo,y
		lda datahi,y
		adc #0
		sta datahi,y
		dex
		bne l2
		tsx
		lda STACK+1,x
		sub #1
		sta STACK+1,x
		lda STACK+2,x
		sbc #0
		sta STACK+2,x
		bcs l1
		pla
		pla
		rts

;data	.res    256, $00
.endproc

.proc byte2ten
		jsr sidrand
		asl 
		sta tmp1
		lda #0
		adc #0
		sta tmp1+1		;*2
		lda tmp1
		sta tmp2
		lda tmp1+1
		sta tmp2+1
		asl tmp2
		rol tmp2+1
		asl tmp2
		rol tmp2+1
		lda tmp1
		adc tmp2
		lda tmp1+1
		adc tmp2+1
		rts
.endproc

.proc sidinit
MAX	=	$ffff
C7	=	35115		;C7
C2	=	1097		;C2
		lda #$80
		sta SID+Sid::v3+Voice::ctrl
		lda #>MAX
		sta SID+Sid::v3+Voice::freq+1
		lda #<MAX
		sta SID+Sid::v3+Voice::freq
		rts
.endproc

.proc sidrand
		lda SID+Sid::noise
		rts
.endproc

.proc crc16rand
		lda random
		jsr fetchregs
		asl
		sta random
		rol random+1
		bcc nopoly
		lda random
		eor #$21
		sta random
		lda random+1
		eor #$10
		sta random+1
nopoly:		rts
random:		.word 0
.endproc

.proc fetchregs
		eor $dc04
		eor $d012
		eor $d800
		rts
.endproc

.proc rand
		jsr rand64k
		jsr rand32k
		;lda sr1+1
		;eor sr2+1
		;tay
		lda sr1
		eor sr2
		rts
.endproc

;periode with 65535
;10+12+13+15
.proc rand64k
		lda sr1+1
		asl
		asl
		eor sr1+1
		asl
		eor sr1+1
		asl
		asl
		eor sr1+1
		asl
		rol sr1
		rol sr1+1
		rts
.endproc

;periode with 32767
;13+14
.proc rand32k
		lda sr2+1
		asl
		eor sr2+1
		asl
		asl
		ror sr2
		rol sr2+1
		rts
.endproc

;feel free to set seeds as wished, if put in zeropage some speed-boost is 
;the result. For example sr1=$5c sr2=5e would fit
sr1:	.word $a55a
sr2:	.word $7653
tmp1:	.word 0
tmp2:	.word 0