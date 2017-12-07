;xa -O PETSCII -o usrmod.prg usrmod.asm
; Modulo function using USR()
; Copyright 1992,1999 Peter Karlsson
; For Go64!/Commodore World magazine

         *= 49152
	.text
	.word *
	*= *-2
; BASIC ROM entry points used

usrvec   = $0311
mov2f57  = $bbca
mov2f5c  = $bbc7
frmnum   = $ad8a
fdivmem  = $bb0f
int      = $bccc
fmultmem = $ba28
fsubmem  = $b850
tmp1     = $57
tmp2     = $5c

; Setup the USR vector
         lda #<modulo
         ldx #>modulo
         sta usrvec
         stx usrvec+1
         rts

; Entry point for the USR function
modulo   ; Move numerator (FAC1) to TMP1
         jsr mov2f57

         ; Retrieve denominator and
         ; move from FAC1 to TMP2
         jsr frmnum
         jsr mov2f5c

         ; Calculate FAC1=FAC1/TMP1
         ;           retval=x/y
         lda #<tmp1
         ldy #>tmp1
         jsr fdivmem

         ; Calculate FAC1=INT(FAC1)
         ;           retval=int(x/y)
         jsr int

         ; Calculate FAC1=FAC1*TMP2
         ;           retval=int(x/y)*y
         lda #<tmp2
         ldy #>tmp2
         jsr fmultmem

         ; Calculate FAC1=TMP1-FAC1
         ;           retval=x-int(x/y)*y
         ;                 =mod(x,y)
         lda #<tmp1
         ldy #>tmp1
         jmp fsubmem
