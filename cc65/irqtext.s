;Irqtext
;C64-Programm unter cc65/as65 cross-compiler/assembler
;läßt den Screen im "Fluganzeigetafel"-Stil die Zielzeichen 
;herunterzählen. 
;SYS12*4096 zum Starten
;SYS12*4096+3 zum Speichern des aktuellen Screens
;compile mit
;ca65 -t c64 irqtext.s
;ld65 -t c64 -o irqtext irqtext.o
;Für Forum-64 http://www.forum64.de/wbb2/addreply.php?threadid=3579
;Hanno Behrens ©2007 unter GPL
;Email: pebbles@schattenlauf.de

	IRQVEC=$0314
	SCREEN=$0400
	.macpack generic

	.segment "STARTUP"

	.org $c000
		.word *
		.org *-2
		jmp irqinit
		jmp savescreen
.proc irqinit
		sei
		lda IRQVEC
		sta JMPBACK+1
		lda IRQVEC+1
		sta JMPBACK+2
		lda #<irqstart
		sta IRQVEC
		lda #>irqstart
		sta IRQVEC+1
		cli
		rts
.endproc

.proc irqoff
		lda JMPBACK+1
		sta IRQVEC
		lda JMPBACK+2
		sta IRQVEC+1
		rts
.endproc
		
.proc irqstart
		ldx #0
		ldy #0
loop:		lda SCREEN,y
		cmp scrsav,y
		beq :+
		sub #1
		and #$7f
		sta SCREEN,y
		ldx #1
:		lda SCREEN+$100,y
		cmp scrsav+$100,y
		beq :+
		sub #1
		and #$7f
		sta SCREEN+$100,y
		ldx #1
:		lda SCREEN+$200,y
		cmp scrsav+$200,y
		beq :+
		sub #1
		and #$7f
		sta SCREEN+$200,y
		ldx #1
:		lda SCREEN+$300,y
		cmp scrsav+$300,y
		beq :+
		sub #1
		and #$7f
		sta SCREEN+$300,y
		ldx #1
:		iny
		bne loop
		dex
		beq JMPBACK
		jsr irqoff
.endproc
JMPBACK:	jmp $0000


.proc savescreen
		ldy #0
loop:		lda SCREEN,y
		and #$7f
		sta scrsav,y
		lda SCREEN+$100,y
		and #$7f
		sta scrsav+$100,y
		lda SCREEN+$200,y
		and #$7f
		sta scrsav+$200,y
		lda SCREEN+$300,y
		and #$7f
		sta scrsav+$300,y
		iny
		bne loop
		rts
.endproc

scrsav:		.res $0400,$20