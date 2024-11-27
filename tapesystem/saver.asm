;BEFORE COMPILING THIS IN C64STUDIO. ADD TO POSTBUILD (PROPERTIES):
;c:\exomizer\win32\exomizer.exe sfx $c000 saver.prg -o saver.prg -n


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
	
	;LOAD ADDRESS FOR MAIN PROGRAMS TO BE MASTERED
	GAMESTART = $0801
	MUSICSTART = $1000
	BITMAPSTART = $6000
	BITMAPEND = $7F40
	VIDRAMSTART = $7F40
	VIDRAMEND = $8328
	COLRAMSTART = $8328
	COLRAMEND = $8710
	
	*=$0801
TAPETURBOSTART	
	!bin "loaderinstall.prg",,2
TAPETURBOEND
	*=$c000
	JSR SAVEHEADER
	jmp MASTER
SAVEROUTINE	
	SEI
	JSR $F838	; Show 'Press record and play on tape' message and wait
	LDA #0          ; until the user does that
	STA $90		; Initialise system's status variable (0 - no error)
  LDA DATASAVESTART		; LO-Byte of the save add. (This is where the prg. we
	STA SLBS        ; are saving is in memory)
	LDA DATASAVESTART+1	; HI-Byte...
	STA SHBS
	LDA DATASAVEEND	; LO-Byte of end address
	STA SLBE
	LDA DATASAVEEND+1	; HI-Byte...
	STA SHBE
	LDA DATALOADSTART	; LO-Byte of the load add. (Where the prg. should be
	STA LLBS        ; loaded)
	LDA DATALOADSTART+1; HI-Byte...
	STA LHBS
	LDA DATALOADEND; LO-Byte of end address
	STA LLBE
	LDA DATALOADEND+1; HI-Byte...
	STA LHBE
	
	LDA $D011	; Disable VIC-II (This has to be done because of
	AND #$EF        ; badlines
	STA $D011
	LDA $01		; Disable BASIC ROM and enable cass. motor
	AND #$DE
	STA $01
	LDX #$00	; Make a short pause so the cass. motor can reach the
	LDY #$00        ; needed speed
PAUSE	DEY
	BNE PAUSE
	DEX
	BNE PAUSE
	LDA #$02	; Length of synchronisation record
	STA SYNCLEN
	JSR SYNCHRO	; Write synchronisation
	LDY #$00
	LDX #$1E	; X is used for the Time Constant (TC) needed for the
CONT	LDA LLBS,Y     ; pulse length
	JSR SAVE
	LDX #$22	; TC
	INY
	CPY #$04
	BNE CONT
	LDY #$00
	STY CHECKSUM
	LDX #$22	; TC
MORE	LDA (SLBS),Y	; Get byte of the program
	JSR SAVE	; Save the byte on tape
	LDX #$1F	; TC
	INC SLBS
	BNE INCR
	INC SHBS
	DEX		; TC = TC - 2 (because INC SHBS steals some cycles)
	DEX
INCR	LDA SLBS	; All bytes saved ?
	CMP SLBE
	LDA SHBS
	SBC SHBE
	BCC MORE	; No, save more
	LDX #$20	; TC
	LDA CHECKSUM	; Save the CHECKSUM
	JSR SAVE
	LDA $01		; Disable cass. motor and enable BASIC ROM again
	ORA #$21
	STA $01
	LDA $D011	; Enable VIC-II
	ORA #$10
	STA $D011
	LDA #$01	; CAS1 (This is a system variable. 1 - cass. motor off)
	STA $C0
	CLI
	RTS

SYNCHRO LDY #$00
	LDX #$25	; TC
NEXT	LDA #$02	; 2 is the synchro byte
	JSR SAVE	; Save it
	LDX #$23	; TC
	INY
	BNE NEXT	; Save more synchro bytes
	LDX #$22	; TC
	DEC SYNCLEN
	BNE NEXT	; Save more synchro bytes
	LDX #$22	; TC
	LDA #$5A	; Synchro check byte
	JSR SAVE	; Save it
	RTS

SAVE	STA BUFFER	; Store the byte in a buffer
	EOR CHECKSUM
	STA CHECKSUM	; Calculate checksum
	LDA #$08
	STA BITCNT	; Initialise bit counter
GO	ASL BUFFER
	JSR WAIT	; Make the needed delay
	DEC BITCNT
	BNE GO
	RTS

WAIT	LDA #$06	; Used for inverting the cass. data output line
	JSR WAIT2
	LDX #$2A	; TC
	LDA #$0E	; Used for inverting the cass. data output line
	JSR WAIT2
	LDX #$26	; TC
	RTS

WAIT2	DEX
	BNE WAIT2	; Make the needed delay
	BCC B0		; If recording a 0 bit, no more delay needed
	LDX #$15	; TC
B1	DEX
	BNE B1		; Make more delay if bit 1
B0	STA $01		; Record a pulse on tape
	RTS
	
DISKLOADER	
	  		LDA #$10
NAMELO   LDX #$ff
NAMEHI   LDY #$ff
        JSR $FFBD     ; call SETNAM
        LDA #$01
        LDX $BA       ; last used device number
        BNE .skip
        LDX #$08      ; default to device 8
.skip   LDY #$00      ; $00 means: load to new address
        JSR $FFBA     ; call SETLFS

ADDRLO  LDX #$00
ADDRHI  LDY #$00
        LDA #$00      ; $00 means: load to memory (not verify)
        JSR $FFD5     ; call LOAD
				STX ENDBYTEADDR
				STY ENDBYTEADDR+1
        BCS .error    ; if carry set, a load error has happened
        RTS
.error
        ; Accumulator contains BASIC error code

        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)
        ; A = $04 (FILE NOT FOUND)
        ; A = $1D (LOAD ERROR)
        ; A = $00 (BREAK, RUN/STOP has been pressed during loading)

       	inc $d020
				jmp *-3 
        RTS
MASTER
				;LOAD MUSIC 
				LDX #<MUSICFILENAME
				LDY #>MUSICFILENAME
				STX NAMELO+1
				STY NAMEHI+1
				LDX #<MUSICSTART
				LDY #>MUSICSTART
				STX ADDRLO+1
				STY ADDRHI+1
				JSR DISKLOADER
				;SETUP TAPE LOADER / SAVE ADDRESSES 
				LDX #<MUSICSTART
				LDY #>MUSICSTART
				STX DATASAVESTART
				STY DATASAVESTART+1
				LDX ENDBYTEADDR
				LDY ENDBYTEADDR+1
				STX DATASAVEEND
				STY DATASAVEEND+1
				LDX #<MUSICSTART
				LDY #>MUSICSTART
				STX DATALOADSTART
				STY DATALOADSTART+1
				LDX ENDBYTEADDR
				LDY ENDBYTEADDR+1
				STX DATALOADEND
				STY DATALOADEND+1
				;SAVE STORED INFO TO TAPE TURBO
				JSR SAVEROUTINE
				
				;LOAD KOALAPAINT PICTURE
				LDX #<PICFILENAME
				LDY #>PICFILENAME
				STX NAMELO+1
				STY NAMEHI+1
				LDX #<BITMAPSTART
				LDY #>BITMAPSTART
				STX ADDRLO+1
				STY ADDRHI+1
				JSR DISKLOADER
				
				;CUT PIC INFO INTO SEGMENTS - STARTING WITH THE VIDEORAM 
				LDX #<VIDRAMSTART
				LDY #>VIDRAMSTART
				STX DATASAVESTART
				STY DATASAVESTART+1
				LDX #<VIDRAMEND
				LDY #>VIDRAMEND
				STX DATASAVEEND
				STY DATASAVEEND+1
				LDX #$00
				LDY #$C0
				STX DATALOADSTART
				STY DATALOADSTART+1
				LDX #$E8
				LDY #$C3
				STX DATALOADEND
				STY DATALOADEND+1
				JSR SAVEROUTINE 
				
				;NOW COLOUR RAM DATA - PLACE IT INTO COLOUR RAM MEMORY 
				LDX #<COLRAMSTART
				LDY #>COLRAMSTART
				STX DATASAVESTART
				STY DATASAVESTART+1
				LDX #<COLRAMEND
				LDY #>COLRAMEND
				STX DATASAVEEND
				STY DATASAVEEND+1
				LDX #$00
				LDY #$D8
				STX DATALOADSTART
				STY DATALOADSTART+1
				LDX #$E8
				LDY #$DB
				STX DATALOADEND+1
				STY DATALOADEND+1
				JSR SAVEROUTINE
				
				;FINALLY THE BITMAP
				
				LDX #<BITMAPSTART
				LDY #>BITMAPSTART
				STX DATASAVESTART
				STY DATASAVESTART+1
				LDX #<BITMAPEND
				LDY #>BITMAPEND
				STX DATASAVEEND
				STY DATASAVEEND+1
				LDX #$00
				LDY #$E0
				STX DATALOADSTART
				STY DATALOADSTART+1
				LDX #$40
				LDY #$FF
				STX DATALOADEND
				STY DATALOADEND+1
				JSR SAVEROUTINE
				
				;NOW LOAD IN THE MAIN GAME 
				
				LDX #<GAMEFILENAME
				LDY #>GAMEFILENAME
				STX NAMELO+1
				STY NAMEHI+1
				LDX #$01
				LDY #$08
				STX ADDRLO+1
				STY ADDRHI+1
				JSR DISKLOADER
				
				;NOW SPLIT THE GAME DATA - SEGMENT 1 ($2000-SPECIFIC END ADDRESS)
				
				LDX #$00
				LDY #$20
				STX DATASAVESTART
				STY DATASAVESTART+1
				LDX ENDBYTEADDR
				LDY ENDBYTEADDR+1
				STX DATASAVEEND
				STY DATASAVEEND+1
				LDX #$00
				LDY #$20
				STX DATALOADSTART
				STY DATALOADSTART+1
				LDX ENDBYTEADDR
				LDY ENDBYTEADDR+1
				STX DATALOADEND
				STY DATALOADEND+1
				JSR SAVEROUTINE
				
				;FINALLY SPLIT THE LAST SEGMENT ($7000-END)
				
				LDX #$01
				LDY #$08
				STX DATASAVESTART
				STY DATASAVESTART+1
				LDX #$00
				LDY #$20
				STX DATASAVEEND
				STY DATASAVEEND+1
				LDX #$01
				LDY #$08
				STX DATALOADSTART
				STY DATALOADSTART+1
				LDX #$00
				LDY #$20
				STX DATALOADEND
				STY DATALOADEND+1
				JSR SAVEROUTINE
				JMP $FCE2

SAVEHEADER
				LDA #$10
				LDX #<SAVENAME
				LDY #>SAVENAME
				JSR $FFBD
				LDA #$00
				LDX #$01
				LDY #$00
				JSR $FFBA
				
				LDA #<TAPETURBOSTART
				STA $C1
				LDA #>TAPETURBOSTART
				STA $C2
				LDX #<TAPETURBOEND
				LDY #>TAPETURBOEND
				LDA #$C1
				JSR $FFD8
				lda #$08
				sta $ba
				
				RTS

DATASAVESTART !byte 0,0
DATASAVEEND		!byte 0,0
DATALOADSTART !byte 0,0
DATALOADEND		!byte 0,0
ENDBYTEADDR		!BYTE 0,0
							!ct scr
MUSICFILENAME !text "LOADERTUNE***********"
PICFILENAME   !text "DELTAPIC*************"
GAMEFILENAME  !text "DELTARUN*************"
SAVENAME      !byte 147,5
							!text "DELTA RUN          "