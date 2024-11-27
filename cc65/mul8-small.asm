; General 8bit * 8bit = 8bit multiply
; Multiplies "num1" by "num2" and returns result in .A

; by White Flame (aka David Holz) 20030207

; Input variables:
;   num1 (multiplicand)
;   num2 (multiplier), should be small for speed
;   Signedness should not matter

; .X and .Y are preserved
; num1 and num2 get clobbered

; Instead of using a bit counter, this routine ends when num2 reaches zero, thus saving iterations.

 lda #$00
 beq enterLoop

doAdd:
 clc
 adc num1

loop:
 asl num1
enterLoop: ;For an accumulating multiply (.A = .A + num1*num2), set up num1 and num2, then enter here
 lsr num2
 bcs doAdd
 bne loop

end:

; 15 bytes