;Cybertronics Studios (Laze Ristoski's) IRQ Turbo Tape
;system. With slightly modified code by Richard/TND.


	SLBS     = $00AC	;Low byte of saving start address (TO TAPE)
	SHBS     = $00AD  ;Hi byte of saving start address (TO TAPE)
	SLBE     = $00AE  ;Low byte of saving end address (TO TAPE)
	SHBE     = $00AF	;Hi byte of saving end address (TO TAPE)
	LLBS     = $0002	;Low byte of NEW ADDRESS START (To load from tape)
	LHBS     = $0003	;Hi byte of NEW ADDRESS START (To load from tape)
	LLBE     = $0004  ;Low byte of NEW ADDRESS END (To load from tape)
	LHBE     = $0005  ;Hi byte of NEW ADDRESS END (To load from tape)
	SYNCLEN  = $00AB  ;Length of Synchronised loading
	CHECKSUM = $00D7	;Length of checksum during loading
	BUFFER   = $00BD	;Buffer 
	BITCNT   = $00A3	;Bit counter 
	
	;This next line is for standard INIT/PLAY addresses (JCH, DMC, GoatTracker, Cheesecutter ETC). 
	;NOTE: If using GoatTracker tunes. Make sure they don't use zeropages ($fc-$ff), as the loader 
	;uses these as file check pointers. 
	
	MUSICINIT = $1000 ;Music initialise
	MUSICPLAY = $1003 ;Music play
	GAMESTART = $080D ;Decruncher address (Usually for Exomizer, PuCrunch, MZP, Cruel V2.0+, etc!
										;BASIC users, please use TND's KERNAL linker program at (http://tnd64.unikat.sk/download_utils.html)
										;then set $0810 as GAMESTART!
										
						 !to "loader.prg",cbm
						 *=$0400	;I'm placing code at the SCREEN RAM here.
	 						
	SEI

	LDA #$00	; Set black screen
	STA $D020
	STA $D021
	LDA #$00	; Set start and end addresses of the bitmap
	LDX #$E0
	STA $AC
	STX $AD
	LDA #$40
	LDX #$FF
	STA $AE
	STX $AF
	LDY #$00	; Clear the bitmap
CLRMAP	LDA #$00
	STA ($AC),Y
	INC $AC
	BNE INCR1
	INC $AD
INCR1	LDA $AC
	CMP $AE
	LDA $AD
	SBC $AF
	BCC CLRMAP	; If not all cleared, clear more
	LDA #$7B  ;I don't like the full screen off, so just a black screen and border! :)
	STA $D011	; Disable VIC-II (because the bitmap is still not loaded)
	; Disable KERNAL and BASIC ROM and enable cass. motor
	LDA #$05
	STA $01
	LDA #$00	; Disable VIC-II interupts
	STA $D01A
	LDA $D019	; Acknowledge VIC-II interupts
	STA $D019
	LDA #$7F	; Disable CIAs interupts
	STA $DC0D
	STA $DD0D
	LDA #$90	; Enable FLAG (cass. input) interrupt
	STA $DC0D
	LDA #$40	; Set timer value to 576 cycles
	LDX #$02
	STA $DC06
	STX $DC07
	LDA $DC0D	; Acknowledge CIAs interrupts
	LDA $DD0D
	LDA #<NMI	; Initialise NMI vector 
	LDX #>NMI
	STA $FFFA
	STX $FFFB
	LDA #<IRQ	; Initialise IRQ vector
	LDX #>IRQ
	STA $FFFE
	STX $FFFF
	LDA #$08	; Initialise BIT COUNTER
	STA BITCNT
	LDA #$00	; This flag is used as MUSIC PLAY ON/OFF (0-off) because
	STA $FE		; music is still not loaded
	STA $FF		; Flag for the part that is loading
	CLI
NEXT	JSR PRGLOAD	; This routine waits until a part is loaded
	INC $FF		; Increment loading part flag
	LDA $FF
	CMP #$01	; The music has been loaded
	BNE P1
	LDA #$00	; Initialise music
	TAX
	TAY
	JSR MUSICINIT	; The init add. of the music I'm using
	LDA #$01	; Set MUSIC PLAY flag. The music is loaded now, so it
	STA $FE         ; can be played
	JMP NEXT	; Load next part
P1	CMP #$03	; The BITMAP (screen, color and bitmap) only has to be loaded (Draw screen like Ocean loader)
	BNE P2
	LDA #$00	; Change VIC-II bank ($C000-$FFFF)
	STA $DD00
	LDA #$08	; Set bitmap memory
	STA $D018
	LDA #$D8	; Set multi-color mode
	STA $D016
	LDA #$3B	; Set bitmap display mode
	STA $D011

	JMP NEXT	; Load next part
P2	CMP #$05	; First part of game has been loaded (start - $7000)
	BNE P3
	LDA #$00	; Disable music (the game will overlap it)
	STA $FE
	LDX #$18	; Disable SID voices
	LDA #$00
CLSID	STA $D400,X
	DEX
	BPL CLSID
	JMP NEXT	; Load next part
P3	CMP #$06	; All parts loaded ?
	BNE NEXT	; No, load next part.

	SEI
	LDA $01		; Disable cass. motor and enable ROMs again
	ORA #$22
	STA $01
	LDA #$01	; CAS1 (This is a system variable. 1 - cass. motor off)
	STA $C0
	LDA #$00	; SID volume = 0
	STA $D418
	JSR $E5A8	; Kernal routine: Initialise VIC-II
	
	LDA #$03	; Change VIC-II bank ($0000-$3FFF)
	STA $DD00
	LDA #$00	; Black border + screen for professional 
	STA $D020 ; decrunch.
	STA $D021
	
	
	LDX #$00	;For a more professional decomp - fill screen black
BLACKALL
	LDA #$00
	STA $D800,x 
	sta $d900,x 
	sta $da00,x
	sta $dae8,x
	inx
	bne BLACKALL
	CLI
	JMP GAMESTART
                        ; another is used)
PRGLOAD LDA #$00	; Flag: synchronisation reached (0-no, 1-yes)
	STA $FC
	STA $FD		; Flag: part loaded (0-no, 1-yes)
	STA CHECKSUM	; Initialise checksum
WAIT	LDA $D012	; A routine for playing the music
	CMP #$7C
	BMI NOMUSIC
	CMP #$84
	BPL NOMUSIC
	LDA $FE		; MUSIC PLAY Flag (1-play, 0-no)
	BEQ NOMUSIC
	JSR MUSICPLAY	; The play add. of the music I'm using (IF USING GOAT TRACKER - AVOID ZEROPAGES $02-$04,$FD-$FF)
NOMUSIC LDA $FD		; Is the part loaded ?
	BEQ WAIT 
	RTS

IRQ	PHA
	TXA
	PHA
	TYA
	PHA
	LDA $DC0D	; See if counter has finished counting (no = bit 0,
	LDX #$19	; yes = bit 1). Start counter again
	STX $DC0F
	LSR A		; Get counter finished flag in CARRY
	LSR A
	ROL $BD		; Put the bit in buffer
	
	;Loading stripes (Cyberload style) - You can 
	;alter these to suit your schemem
	
	;---------------------------------------------
	
	LDA $D020	;Two split colours (Black+Green)
  EOR #$05	;The stripes can then cycle (See INC $D020)
  STA $D020 
	
	;---------------------------------------------
	LDA $BD
	LDX $FC
	BEQ GETSYNCHRO	; If no synchronisation, reach it
	DEC BITCNT
	LDX BITCNT
	BEQ CONT
	JMP RET
CONT
	
	LDX #$08
	STX BITCNT
	LDX $FC
	CPX #$01
	BEQ TEST	; Synchro Check Byte
	CPX #$02
	BEQ ADDRESS	; Start and end address
	CPX #$03
	BEQ PROGRAM	; Main part
	CPX #$04
	BEQ CHKSUM	; Checksum

GETSYNCHRO
	CMP #$02	; 2 is the synchro byte
	BNE RET
	INC $FC
	JMP RET

TEST	CMP #$5A	; $5A is the synchro check byte
	BEQ GOOD
	LDA #$00	; Synchronisation invalid. Retry
	STA $FC
	JMP RET
GOOD	INC $FC
	LDA #$AC	; $00AC is the place in memory where we keep the start
	LDX #$00        ; and end address
	STA $02
	STX $03
	JMP RET

ADDRESS LDY #$00
	STA ($02),Y
	INC $02
	LDA $02
	CMP #$B0	; All bytes of the address read ?
	BNE RET
	INC $FC

	JMP RET

PROGRAM LDY #$00
	STA ($AC),Y	; Store byte in memory
	EOR CHECKSUM	; Calculate checksum
	STA CHECKSUM
	INC $AC
	BNE INCR2
	INC $AD
	INC $D020 	;Full block of data has now loaded. Cycle border once!
INCR2	LDA $AC
	CMP $AE
	LDA $AD
	SBC $AF
	BCC RET
	INC $FC
	
	JMP RET

CHKSUM	CMP CHECKSUM
	BNE ERROR
	LDA #$00	; Set no synchronisation (for the next part)
	STA $FC
	LDA #$01	; Part loaded flag
	STA $FD
	JMP RET 

ERROR	LDA $01		; Disable cass. motor
	ORA #$20
	STA $01
	LDA #$02	; Set red border indicating load error
	STA $D020
	LDA #$00	; Set SID volume to 0
	STA $D418
LOOP	JMP LOOP	; Endless loop

RET	LDA $DC0D	; Acknowledge interrupt
	PLA
	TAY
	PLA
	TAX
	PLA
NMI	RTI
!align $20,$00
;I think it would be fair to also add a credit inside the loader's code
;to the original author who was kind enough to have coded the loadera
!ct scr
!text "TAPE LOADER BY CYBERNATOR/CYBERTRONIC STUDIOS"
