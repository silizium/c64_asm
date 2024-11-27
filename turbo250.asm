; acme -o turbo250 turbo250.asm
;============================================================================

		* =  $0801

basic_startup:
		!byte  $10 ;  
		!byte	 8 ;  
		!byte	$A ;  
		!byte	 0 ;  
		!byte  $9E ;
		!byte  $32 ; 2
		!byte  $30 ; 0
		!byte  $36 ; 6
		!byte  $36 ; 6
		!byte  $20 ;  
eorval1:	!byte  $4D ; M
eorval2:	!byte  $52 ; R
eorval3:	!byte  $2E ; .
eorval4:	!byte  $5A ; Z
		!byte	 0 ;  
		!byte	 0 ;  
		!byte	 0 ;  
;============================================================================
;		ldx	lamerprotection
;		stx	$fb
		ldx #0

printmsg:				; code xref: 0824j
		lda	string,x ;lda string-$4d,x	;$4d = EOR instructino at lamerprotection
		beq	lamerprotection	;bypass message 
		jsr	$e716
;		eor	$fb
;		sta	$fb
		inx	
		bne	printmsg

lamerprotection:		; code xref: 081aj
					; data xref: 0812r
		eor	#$ff	; a=ff x=fa y=90 fb=d5
		tay			
		iny	
		ldx	#$ff
		txs	
		ldx	#$55

copy1:				; code xref: 083dj
		lda	code1,y	; y=0
;		eor	$fb		; fb=d5
;		eor	$7b6,x	; 080d=$4d
		sta	$2a7,y
		iny	
		cpy	#$58
		bne	copy1
		ldy	#0

copy2:				; code xref: 084fj
		lda	code2,y
;		eor	$fb		; fb=d5
;		eor	$7b7,x	; 080e=52
		sta	$334,y
		iny	
		cpy	#$c7
		bne	copy2
		ldy	#0

copy3:				; code xref: 0861j
		lda	code3,y
;		eor	$fb		; fb=d5
;		eor	$7b8,x	; 080f=2e
		sta	$10b,y
		iny	
		cpy	#$97
		bne	copy3
		ldy	#0

copy4:				; code xref: 0873j
		lda	code4,y
;		eor	$fb		; fb=d5
;		eor	$7b9,x	; 0810=5a
		sta	$ff3b,y
		iny	
		cpy	#$c5
		bne	copy4
		lda	#$a7
		ldx	#2
		sta	$308	; basic	caracter dispatch
		stx	$309
		jmp	$a474	; restart basic
;============================================================================
string:		!byte  $93 ; “
		!byte  $8E ; Ž
		!byte  $B0 ; °
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $AE ; ®
		!byte	$D ;  
		!byte  $C2 ; Â
		!byte  $20 ;  
		!byte  $54 ; T
		!byte  $55 ; U
		!byte  $52 ; R
		!byte  $42 ; B
		!byte  $4F ; O
		!byte  $20 ;  
		!byte  $32 ; 2
		!byte  $35 ; 5
		!byte  $30 ; 0
		!byte  $20 ;  
		!byte  $42 ; B
		!byte  $59 ; Y
		!byte  $20 ;  
		!byte  $4D ; M
		!byte  $52 ; R
		!byte  $2E ; .
		!byte  $5A ; Z
		!byte  $20 ;  
		!byte  $C2 ; Â
		!byte	$D ;  
		!byte  $C2 ; Â
		!byte  $43 ; C
		!byte  $41 ; A
		!byte  $4E ; N
		!byte  $20 ;  
		!byte  $48 ; H
		!byte  $41 ; A
		!byte  $4E ; N
		!byte  $44 ; D
		!byte  $4C ; L
		!byte  $45 ; E
		!byte  $20 ;  
		!byte  $50 ; P
		!byte  $52 ; R
		!byte  $4F ; O
		!byte  $47 ; G
		!byte  $52 ; R
		!byte  $41 ; A
		!byte  $4D ; M
		!byte  $53 ; S
		!byte  $C2 ; Â
		!byte	$D ;  
		!byte  $C2 ; Â
		!byte  $42 ; B
		!byte  $45 ; E
		!byte  $54 ; T
		!byte  $57 ; W
		!byte  $45 ; E
		!byte  $45 ; E
		!byte  $4E ; N
		!byte  $20 ;  
		!byte  $24 ; $
		!byte  $30 ; 0
		!byte  $38 ; 8
		!byte  $30 ; 0
		!byte  $31 ; 1
		!byte  $2D ; -
		!byte  $24 ; $
		!byte  $46 ; F
		!byte  $46 ; F
		!byte  $33 ; 3
		!byte  $42 ; B
		!byte  $C2 ; Â
		!byte	$D ;  
		!byte  $AB ; «
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $B3 ; ³
		!byte	$D ;  
		!byte  $C2 ; Â
		!byte  $5F ; _
		!byte  $4C ; L
		!byte  $20 ;  
		!byte  $20 ;  
		!byte  $20 ;  
		!byte  $20 ;  
		!byte  $20 ;  
		!byte  $20 ;  
		!byte  $20 ;  
		!byte  $20 ;  
		!byte  $4C ; L
		!byte  $4F ; O
		!byte  $41 ; A
		!byte  $44 ; D
		!byte  $20 ;  
		!byte  $50 ; P
		!byte  $52 ; R
		!byte  $4F ; O
		!byte  $47 ; G
		!byte  $C2 ; Â
		!byte	$D ;  
		!byte  $C2 ; Â
		!byte  $5F ; _
		!byte  $53 ; S
		!byte  $20 ;  
		!byte  $28 ; (
		!byte  $4E ; N
		!byte  $41 ; A
		!byte  $4D ; M
		!byte  $45 ; E
		!byte  $29 ; )
		!byte  $20 ;  
		!byte  $53 ; S
		!byte  $41 ; A
		!byte  $56 ; V
		!byte  $45 ; E
		!byte  $20 ;  
		!byte  $50 ; P
		!byte  $52 ; R
		!byte  $4F ; O
		!byte  $47 ; G
		!byte  $C2 ; Â
		!byte	$D ;  
		!byte  $AD ; ­
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $C3 ; Ã
		!byte  $BD ; ½
		!byte	 0 ;  

;##################################################################################
;##################################################################################
;##################################################################################
code1:
!pseudopc $2a7 {
;============================================================================
		JSR	$73
		BEQ	loc_0_2B0
		CMP	#$5F
		BEQ	loc_0_2B3

loc_0_2B0:				; CODE XREF: 02AAj
		JMP	$A7E7
;============================================================================

loc_0_2B3:				; CODE XREF: 02AEj
		JSR	$73
		CMP	#$4C
		BEQ	loc_0_2C1
		CMP	#$53
		BEQ	loc_0_2C4
		JMP	$AF08
;============================================================================

loc_0_2C1:				; CODE XREF: 02B8j
		JMP	loc_0_111
;============================================================================

loc_0_2C4:				; CODE XREF: 02BCj
		JMP	loc_0_120
;============================================================================

loc_0_2C7:				; CODE XREF: 011Aj
		LDX	#0
		STX	$A
		STX	$93
		STX	$90

loc_0_2CF:				; CODE XREF: 02DAj
		JSR	loc_0_334
		LDA	$AB
		CMP	#1
		BEQ	loc_0_2DC
		CMP	#2
		BNE	loc_0_2CF

loc_0_2DC:				; CODE XREF: 02D6j
		DEC	$B3
		JSR	$F750
		INC	$B3
		JSR	$A82C
		JSR	$F5D2
		JSR	loc_0_355
		LDA	$BD
		EOR	$D7
		BEQ	loc_0_2F6
		LDA	#$FF
		STA	$90

loc_0_2F6:				; CODE XREF: 02F0j
		JSR	$F5A9
		JSR	$E195
		JMP	$A7AE
;============================================================================

}


;##################################################################################
;##################################################################################
;##################################################################################
code2:
!pseudopc $334 {
;============================================================================

loc_0_334:				; CODE XREF: 0339j
		JSR	sub_0_388
		CMP	#0
		BEQ	loc_0_334
		STA	$AB

loc_0_33D:				; CODE XREF: 0346j
		JSR	sub_0_3B6
		STA	$AC,Y
		INY	
		CPY	#5
		BNE	loc_0_33D

loc_0_348:				; CODE XREF: 0351j
		JSR	sub_0_3B6
		STA	$23C,Y
		INY	
		CPY	#$15
		BNE	loc_0_348
		BEQ	sub_0_37C

loc_0_355:
		JSR	sub_0_388

loc_0_358:				; CODE XREF: 0373j
		JSR	sub_0_3B6
		LDA	#4
		STA	1
		LDA	$BD
		STA	($AC),Y
		LDA	#7
		STA	1
		LDA	$BD
		EOR	$D7
		STA	$D7
		JSR	$FCDB
		JSR	$FCD1
		BCC	loc_0_358
		JSR	sub_0_3B6
		JSR	sub_0_3E0
		INY	

;############################################################################

;		S u b r	o u t i	n e

sub_0_37C:				; CODE XREF: 017Cp 0353j
		STY	$C0
		CLI	
		CLC	
		LDA	#0
		STA	$2A0
		JMP	$FC93
; End of function sub_0_37C


;############################################################################

;		S u b r	o u t i	n e

sub_0_388:				; CODE XREF: 0334p 0355p
		JSR	loc_0_10B
		JSR	sub_0_3E0
		STY	$D7
		LDA	#7
		STA	$DD06
		LDX	#1

loc_0_397:				; CODE XREF: sub_0_388+18j
					; sub_0_388+25j
		JSR	sub_0_3C9
		ROL	$BD
		LDA	$BD
		CMP	#2
		BNE	loc_0_397
		LDY	#9

loc_0_3A4:				; CODE XREF: sub_0_388+21j
		JSR	sub_0_3B6
		CMP	#2
		BEQ	loc_0_3A4

loc_0_3AB:				; CODE XREF: sub_0_388+2Bj
		CPY	$BD
		BNE	loc_0_397
		JSR	sub_0_3B6
		DEY	
		BNE	loc_0_3AB
		RTS	
	; End of function sub_0_388


	;############################################################################

	;		S u b r	o u t i	n e

sub_0_3B6:				; CODE XREF: 033Dp 0348p 0358p 0375p
					; ...
		LDA	#8
		STA	$A3

loc_0_3BA:				; CODE XREF: sub_0_3B6+Ej
		JSR	sub_0_3C9
		ROL	$BD
		NOP	
		NOP	
		NOP	
		DEC	$A3
		BNE	loc_0_3BA
		LDA	$BD
		RTS	
	; End of function sub_0_3B6


	;############################################################################

	;		S u b r	o u t i	n e

sub_0_3C9:				; CODE XREF: sub_0_388+Fp sub_0_3B6+4p
		LDA	#$10

loc_0_3CB:				; CODE XREF: sub_0_3C9+5j
		BIT	$DC0D
		BEQ	loc_0_3CB
		LDA	$DD0D
		STX	$DD07
		PHA	
		LDA	#$19
		STA	$DD0F
		PLA	
		LSR
		LSR
		RTS	
	; End of function sub_0_3C9


	;############################################################################

	;		S u b r	o u t i	n e

sub_0_3E0:				; CODE XREF: 0168p 0378p sub_0_388+3p
		LDY	#0
		STY	$C0
		LDA	$D011
		AND	#$EF
		STA	$D011

loc_0_3EC:				; CODE XREF: sub_0_3E0+Dj sub_0_3E0+10j
		DEX	
		BNE	loc_0_3EC
		DEY	
		BNE	loc_0_3EC
		SEI	
		RTS	
	; End of function sub_0_3E0

	;============================================================================

irq:
		LDA	#$37 ; '7'
		STA	1
		JMP	$FE69
	;============================================================================
}



;##################################################################################
;##################################################################################
;##################################################################################
code3:	;!bin "block3.PRG",,2
		!pseudopc $10b {
	;============================================================================

loc_0_10B:
		JSR	$F817
		JMP	$A82C
	;============================================================================

loc_0_111:
		JSR	$73
		BEQ	loc_0_11A
		CMP	#$3A
		BNE	loc_0_11D

loc_0_11A:				; CODE XREF: 0114j
		JMP	loc_0_2C7
	;============================================================================

loc_0_11D:				; CODE XREF: 0118j
		JMP	$AF08
	;============================================================================

loc_0_120:
		LDX	$37
		LDY	$38
		STX	$FB
		STY	$FC
		LDX	$2D
		LDY	$2E
		STX	$FD
		STY	$FE
		LDX	#$F8
		LDY	#7
		STX	$37
		STY	$38
		LDX	#$E8
		LDY	#7
		STX	$2D
		STY	$2E
		JSR	$A660
		LDX	#$82
		LDY	#1
		STX	$302
		STY	$303
		JSR	$73
		JSR	$E1D4
		LDX	#5
		STX	$AB
		DEX	

loc_0_158:				; CODE XREF: 015Dj
		LDA	$2A,X
		STA	$AB,X
		DEX	
		BNE	loc_0_158
		JSR	$F838
		JSR	$A82C
		JSR	$F68F
		JSR	sub_0_3E0
		SEI	
		LDA	#$7F
		STA	$DD0D
		LDA	#4
		STA	1
		JSR	loc_0_FF3B
		LDA	#7
		STA	1
		JSR	sub_0_37C
		JMP	$A474
	;============================================================================
		LDA	#$83
		STA	$302
		LDA	#$A4
		STA	$303
		LDA	$FB
		STA	$37
		LDA	$FC
		STA	$38
		LDA	$FD
		STA	$2D
		LDA	$FE
		STA	$2E
		JSR	$A660
		JMP	($302)
	;============================================================================
}

;##################################################################################
;##################################################################################
;##################################################################################
code4:
!pseudopc $ff3b {
	;============================================================================

loc_0_FF3B:
		LDA	$FD
		STA	$AE
		LDA	$FE
		STA	$AF
		JSR	sub_0_FFAB
		LDA	$B9
		LDA	#2
		NOP	
		DEX	
		JSR	sub_0_FFCB
		LDX	#8

loc_0_FF51:				; CODE XREF: FF5Dj
		LDA	$AC,Y
		JSR	sub_0_FFCB
		LDX	#6
		INY	
		CPY	#5
		NOP	
		BNE	loc_0_FF51
		LDY	#0
		LDX	#4

loc_0_FF63:				; CODE XREF: FF74j
		LDA	($BB),Y
		CPY	$B7
		BCC	loc_0_FF6C
		LDA	#$20
		DEX	

loc_0_FF6C:				; CODE XREF: FF67j
		JSR	sub_0_FFCB
		LDX	#5
		INY	
		CPY	#$BB
		BNE	loc_0_FF63
		LDA	#2
		STA	$AB
		JSR	sub_0_FFAB
		TYA	
		JSR	sub_0_FFCB
		STY	$D7
		LDX	#7
		NOP	

loc_0_FF86:				; CODE XREF: FF9Dj
		LDA	($AC),Y
		JSR	sub_0_FFCB
		LDX	#3
		INC	$AC
		BNE	loc_0_FF95
		INC	$AD
		DEX	
		DEX	

loc_0_FF95:				; CODE XREF: FF8Fj
		LDA	$AC
		CMP	$AE
		LDA	$AD
		SBC	$AF
		BCC	loc_0_FF86

loc_0_FF9F:				; CODE XREF: FFA7j
		LDA	$D7
		JSR	sub_0_FFCB
		LDX	#7
		DEY	
		BNE	loc_0_FF9F
		INY	
		RTS	

	;############################################################################

	;		S u b r	o u t i	n e

sub_0_FFAB:				; CODE XREF: FF43p FF7Ap
		LDY	#0

loc_0_FFAD:				; CODE XREF: sub_0_FFAB+Cj
					; sub_0_FFAB+12j
		LDA	#2
		JSR	sub_0_FFCB
		LDX	#7
		DEY	
		CPY	#9
		BNE	loc_0_FFAD
		LDX	#5
		DEC	$AB
		BNE	loc_0_FFAD

loc_0_FFBF:				; CODE XREF: sub_0_FFAB+1Bj
		TYA	
		JSR	sub_0_FFCB
		LDX	#7
		DEY	
		BNE	loc_0_FFBF
		DEX	
		DEX	
		RTS	
	; End of function sub_0_FFAB


	;############################################################################

	;		S u b r	o u t i	n e

sub_0_FFCB:				; CODE XREF: FF4Cp FF54p FF6Cp FF7Ep
					; ...
		STA	$BD
		EOR	$D7
		STA	$D7
		LDA	#8
		STA	$A3

loc_0_FFD5:				; CODE XREF: sub_0_FFCB+1Fj
		ASL	$BD
		LDA	1
		AND	#$F7
		JSR	sub_0_FFED
		LDX	#$11
		NOP	
		ORA	#8
		JSR	sub_0_FFED
		LDX	#$E
		DEC	$A3
		BNE	loc_0_FFD5
		RTS	
	; End of function sub_0_FFCB


	;############################################################################

	;		S u b r	o u t i	n e

sub_0_FFED:				; CODE XREF: sub_0_FFCB+10p
					; sub_0_FFCB+18p sub_0_FFED+1j
		DEX	
		BNE	sub_0_FFED
		BCC	loc_0_FFF7
		LDX	#$B

loc_0_FFF4:				; CODE XREF: sub_0_FFED+8j
		DEX	
		BNE	loc_0_FFF4

loc_0_FFF7:				; CODE XREF: sub_0_FFED+3j
		STA	1
		RTS	
	; End of function sub_0_FFED

	;============================================================================
	;Interrupt handler pointers which ends up at $fffa - $ffff
		!WORD irq
		!WORD irq
		!WORD irq
}
