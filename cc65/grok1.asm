; cl65 -t c64 -o grok1 grok1.asm -C crypto/c64-asm.cfg
; Example CALL BY VALUE RETURN

        .setcpu "6502X"
        .macpack generic
        .macpack cbm
        .import c64
        .import BSOUT
        .include "c64.inc"      ;FREKZP=$fb
        .macpack basicstart

.macro Crypt Arg, Code
	.repeat .strlen(Arg), I
	.byte .strat(Arg, I)&$3f ^ Code
	.endrep
.endmacro

;print for by value return
.macro  println text
        jsr printbvr
        .asciiz .sprintf("%s%c",text,13)
.endmacro

        .segment "CODE"

        basicstart 2025

_main:
	code = $42

	LDX #(mesend-message)-1 ; Load X register with 0
loop:			; Label for the loop
	LDA message,X	; Load Accumulator with byte from message + X
	EOR #code		; Exclusive OR Accumulator with $42 (decimal 66)
	STA $0400,X	; Store Accumulator at screen memory $0400 + X
	DEX		; Increment X register
	BPL loop		; Jump back to loop
done:			; Label for end of routine
	RTS		; Return from subroutine
message:			; Label for data
	Crypt "this heart is relentless", code

mesend:
