; cl65 -t c64 -o print print.s -C crypto/c64-asm.cfg
; Example CALL BY VALUE RETURN

	.setcpu "6502X"
	.macpack generic
	.macpack cbm
	.import c64	
	.import BSOUT
	.include "c64.inc"	;FREKZP=$fb
	.macpack basicstart

.define	sid_init	$1000
.define	sid_play	$1003
.define	siddata	$1000
.define	rasterline 250	;7 pre, 43 upper border, 200 screen, 49 lower border, 13 rest

.macro	setSID voice, reg
	sta	SID+voice*7+reg
.endmacro

;print for by value return
.macro	println text
	jsr printbvr
	.asciiz .sprintf("%s%c",text,13)
.endmacro

	.segment "CODE"

	basicstart 2024,2025

_main:
	jmp _setupAndStartPlayer
	jmp _stopPlayer	

.proc _setupAndStartPlayer: near
	lda #$00     ; select first tune
	jsr sid_init ; init music
	; now set the new interrupt pointer
	sei
	lda IRQVec+1
	cmp #>_interrupt	;check if already overwritten
	bne :+
	lda IRQVec
	cmp #<_interrupt
	bne :+
	beq :++
:	lda IRQVec
	sta IRQold+1
	lda IRQVec+1
	sta IRQold+2
:	lda #<_interrupt	; point IRQ Vector to our custom irq routine
	ldx #>_interrupt
	sta IRQVec	; store in $314/$315
	stx IRQVec+1
	lda #<rasterline	;Rasterline
	sta VIC_HLINE
	lda VIC_CTRL1	;Rasterline high bit
	and #$7f
	ora #(>rasterline)<<7
	sta VIC_CTRL1
	lda VIC_IMR	;irq mask
	ora #$01
	sta VIC_IMR
	cli		; clear interrupt disable flag
	rts     
.endproc        

.proc _stopPlayer
	sei
	lda IRQold+1
	sta IRQVec
	lda IRQold+2
	sta IRQVec+1
	lda VIC_IRR
	sta VIC_IRR
	lda VIC_IMR	;irq mask
	and #$fe
	sta VIC_IMR
	cli
	lda #0
	sta SID_Ctl1
	sta SID_Ctl2
	sta SID_Ctl3
	sta SID_Amp
	rts
.endproc

_interrupt:
	lda VIC_IRR	;d019
	bmi vic_irq
	lda CIA1_ICR	;ack timer irq $dc0d
	cli
IRQold:	jmp $EA31 ; do the normal interrupt service routine

vic_irq:	inc VIC_BORDERCOLOR	
	sta VIC_IRR	;ack vic irq

	lda VIC_CTRL1
	and #$80
	cmp #(>rasterline)<<7
	bne :+

	lda VIC_HLINE	;$d012
	cmp #<rasterline
	bne :+

	sta VIC_HLINE
	lda VIC_CTRL1	;Rasterline high bit
	and #$7f
	ora #(>rasterline<<7)
	sta VIC_CTRL1

:	jsr sid_play
	dec VIC_BORDERCOLOR
	pla 
	tay
	pla
	tax
	pla
	rti


endfile: 
	.res siddata-*, $00
	.incbin "lydia.bin" ; if bin else sid 
;	.incbin "music.sid", 2
