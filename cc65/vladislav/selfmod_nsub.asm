.zeropage
MainLoops:		.res 1 ; number of loops

.bss
ForeachStartLo:	.res 1 ; start address (low byte)
ForeachStartHi:	.res 1 ; start address (high byte)
ForeachEndLo:	.res 1 ; end address (low byte)
ForeachEndHi:	.res 1 ; end address (high byte)
ForeachFnLo:	.res 1 ; function to call (low byte)
ForeachFnHi:	.res 1 ; function to call (high byte)

.code
		lda #$ff
		sta MainLoops
		
.proc Main
		lda #$04
		sta ForeachStartHi
		lda #$00
		sta ForeachStartLo
		
		lda #$07
		sta ForeachEndHi
		lda #$e8
		sta ForeachEndLo
		
		lda #>increm
		sta ForeachFnHi
		lda #<increm
		sta ForeachFnLo
		
loop:	jsr Foreach	
		dec MainLoops
		beq end
		jmp loop
		
end:	rts

increm:	clc
		adc #$1
		rts
.endproc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Call function for each byte in a sequence, passing
; the byte as a parameter over the accumulator register.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.proc Foreach
		ldx ForeachStartHi
		stx loadi+2
		stx stai+2
		ldx ForeachStartLo
		stx loadi+1
		stx stai+1
		
		ldx ForeachEndHi
		stx cphi+1
		ldx ForeachEndLo
		stx cplo+1
		
		ldx ForeachFnHi
		stx jsri+2
		ldx ForeachFnLo
		stx jsri+1
		
go:		ldx loadi+1
cplo:	cpx #$78
		bne loadi
		
		ldx loadi+2
cphi:	cpx #$56
		bne loadi
		
		rts
		
loadi:	lda $1234
jsri:	jsr $9abc
stai:	sta $1234
	
		clc
		lda loadi+1
		adc #$1
		sta loadi+1
		sta stai+1
		lda loadi+2
		adc #$0
		sta loadi+2
		sta stai+2
		
		jmp go
.endproc