		processor   6502
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Loader.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		org $0801
		dc.b $0C,$08,$0A,$00,$9E,$20,$34,$30,$39,$36,$00,$00,$00
		org $1000
		jmp main
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main entry point.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
main	subroutine
		lda #$04 ; start hi
		sta $31
		lda #$00 ; start low
		sta $30
		
		lda #$07 ; end high
		sta $33
		lda #$e8 ; end low
		sta $32
		
		lda #[>.increm] ; fn high
		sta $35
		lda #[<.increm] ; fn low
		sta $34
		
		jsr map
		
		jmp main
		
.increm	clc
		adc #$1
		rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Call function for each byte in a sequence, passing
; it as a parameter over the accumulator register.
;
;   H-L
; $31-$30 start
; $33-$32 end
; $35-$34 function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
map		subroutine
		ldx $31
		cpx $33
		bne .go
		
		ldx $30
		cpx $32
		bne .go
		
		rts ; end reached

		; "jsr indirect" into supplied function
.go		lda #[>[.retadr-1]]
		pha
		lda #[<[.retadr-1]]
		pha
		ldy #$0
		lda ($30),Y
		jmp ($34)

.retadr	ldy #$0
		sta ($30),Y
		
		clc
		lda $30		
		adc #$1
		sta $30
		lda $31
		adc #$0
		sta $31
		
		jmp map