.zeropage
MainLoops:		.res 1 ; number of loops
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
		
		jsr Foreach	
		dec MainLoops
		beq end
		jmp Main
		
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
		ldx ForeachStartLo
		cpx ForeachEndLo
		bne go
		
		ldx ForeachStartHi
		cpx ForeachEndHi
		bne go
		
		rts

		; "jsr indirect" into supplied function
go:		lda #>(retadr-1)
		pha
		lda #<(retadr-1)
		pha
		ldy #$0
		lda (ForeachStartLo),Y
		jmp (ForeachFnLo)

retadr:	ldy #$0
		sta (ForeachStartLo),Y
		
		clc
		lda ForeachStartLo	
		adc #$1
		sta ForeachStartLo
		lda ForeachStartHi
		adc #$0
		sta ForeachStartHi
		
		jmp Foreach
.endproc