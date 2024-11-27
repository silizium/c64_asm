;*****************************************************************************
; Epyx Fastload kernal load routine relocated to $C000
; Disassembled February, 2024 by Dave McMurtrie <dave@commodore.international>
;
; This is *not* a complete disassembly of the Epyx Fastload cartridge. I only
; disassembled the loading bits. None of the other code like the machine
; language monitor is included here.
;
; This is *not* an exact disassembly of the Epyx Fastload cartridge.
; It's a disassembly with code modifications which allow the code to run from
; $C000.
;
; All credit goes to Scott Nelson, the original author of Epyx Fastload
;*****************************************************************************

* = $C000

D6510              = $00   ; processor port data direction register
R6510              = $01   ; processor port
CHRGET             = $0073 ; read next byte from BASIC program or direct command
STATUS             = $90   ; Value of ST var - device status for serial bus IO
VERCK              = $93   ; Load/verify flag. $00 = LOAD. $01-$FF = VERIFY
C3P0               = $94   ; Serial bus output cache status
BSOUR              = $95   ; Serial bus output cache, previous byte to be sent to serial bus
R2D2               = $A3   ; EOI switch during serial bus output.
FIRT               = $A4   ; Byte buffer during serial bus input.
CNTDN              = $A5   ; Bit counter during serial bus input/output.
LDADDR             = $AE   ; load address and pointer to current byte during LOAD/VERIFY
FNLEN              = $B7   ; length of filename or disk command
SA                 = $B9   ; Secondary address of current file
FA                 = $BA   ; Device number of current file
LA                 = $BB   ; Logical number of current file
MEMUSS             = $00C3 ; address for secondary address of 0 for load and verify from serial bus
KEYLOG             = $028F ; Execution address of routine that sets keybd matrix
IMAIN              = $0302 ; Execution address of BASIC idle loop.
ILOAD              = $0330 ; Execution address of LOAD
IFLIN              = $A560 ; Input a Line to Buffer from Keyboard
SCROLY             = $D011 ; Vertical Fine Scrolling and Control Register
RASTER             = $D012 ; Read Current Raster Scan Line/Write Line to Compare for Raster IRQ
SPENA              = $D015 ; Sprite Enable Register
ICR                = $D01A ; Interrupt Control Register
D2PRA              = $DD00
LIST1              = $ED11 ; serial LISTN
LUKING             = $F5AF ; print "SEARCHING FOR"
LODING             = $F5D2 ; print "LOADING"
SCINIT             = $FF81 ; Initialize VIC; restore default input/output to keybouard/screen; clear screen 
IOINIT             = $FF84 ; Initialize CIA's, SID volume, setup memory configuration; set and start interrupt timer.
RESTOR             = $FF8A ; Fill vector table at memory addresses $0314-0333 with default values
LSTNSA             = $FF93 ; Send LISTEN secondary address to serial bus.
IECOUT             = $FFA8 ; handshake serial byte out
UNLSTN             = $FFAE ; Send UNLISTEN command to serial bus.
SETLFS             = $FFBA ; Set file parameters.
SETNAM             = $FFBD ; Set file name parameters.

; this wasn't in the original code. I added it to facilitate relocation
DRVLD              = $CFFE

; This was the beginning bytes on the cartridge that aren't needed
; when running from $C000 but I stuck them here for posterity
; and commented them out.
;L8000                          
;.byte $30,$80,$5e,$fe,$c3,$c2,$cd,$38
;.byte $30,$20,$04,$90,$4c,$38,$df,$1a 
;.byte $a6,$28,$43,$29,$20,$31,$39,$38
;.byte $34,$20,$53,$43,$4f,$54,$54,$20 
;.byte $4e,$45,$4c,$53,$4f,$4e,$0d,$46  
;.byte $41,$53,$54,$4c,$4f,$41,$44,$8d  

; $8030 is the coldstart vector in Epyx Fastload.
; When you initially boot the C64 with the FastLoad cartridge inserted,
; execution begins here to do all the setup and initialization.
; When relocated to $C000, this will be $C000 and the initialization will
; run when you SYS 49152
L8030                SEI
                     CLD
                     LDX #$FF
                     TXS
                     LDA #%00100111
                     STA R6510 ; Bits 0-2 = 111
                               ; %x11 = BASIC ROM visible at $A000-$BFFF
                               ;        KERNAL ROM visible at $E000-$FFFF
                               ; Bit 5 = 1 = Datasette motor conrol off
                     LDA #$2F
                     STA D6510 ; default setting 
                     JSR IOINIT
                     JSR L80FA ; initialize zero page and $0200-$03FF
                     JSR RESTOR
                     JSR SCINIT
                     JSR L80C3 ; hijack the kernal LOAD vector
                     JSR L8057
                     RTS

L8057                LDX #$09
                     STX $C6     ; set length of keyboard buffer to #$09
L805B                LDA LC000,X ; load a byte of the FASTLOAD greeting
                     STA $0276,X ; store it in the keyboard buffer
                     DEX         ; to display the FASTLOAD greeting
                     BNE L805B
L80A2                LDX #$08
                     STX FA      ; set device number to 08
                     LDA #%00100111
                     STA CNTDN ; will be used to set R6510 in LDF34 below
                               ; ; Bits 0-2 = 111
                               ; %x11 = BASIC ROM visible at $A000-$BFFF
                               ;        KERNAL ROM visible at $E000-$FFFF
                               ; Bit 5 = 1 = Datasette motor conrol off
                     LDX #$FB 
                     TXS         ; set the stack pointer to $FB
                                 ; running in a debugger shows it was $FD,
                                 ; so this is a way to slide another call
                                 ; in when RTS is executed
                     LDA #%00110100
                     PHA
                     PLP         ; sets the status register to %00110100
                                 ; Carry: 0
                                 ; Zero:  0
                                 ; Interrupt Disable: 1
                                 ; Decimal: 0
                                 ; Break: 1
                                 ; Unused: 1
                                 ; Overflow: 0
                                 ; Negative: 0
                     LDA #$E3
                     PHA
                     LDA #$96
                     PHA         ; sets up return address of $E397 on stack
                                 ; (kernal reset routine)
                     JMP LDF34   ; set R6510 and RTS to $E397 to reset


L80C3                JSR LDF64   ; copy BASIC vectors to RAM
L80C6                LDA #>LOAD  ; hijack the kernal load vector
                     STA ILOAD+1
                     LDA #<LOAD
                     STA ILOAD 
L80f9                RTS

L80FA                LDA #$00
                     TAY
L80FD                STA $0200,Y ; initialize $0200-$02FF to #$00
                     STA $0300,Y ; initialize $0300-$03FF to #$00
                     STA $0002,Y ; initialize $0002-$00FF to #$00
                     INY
                     BNE L80FD
                     LDA #$3C
                     LDX #$03 ; put the tape buffer pointer ($033C) back
                     STA $B2
                     STX $B3
                     LDY #$A0  ; put "end of BASIC" ($A000) back
                     STY $0284
                     LDA #$08  ; put "beginning of BASIC" ($0800) back
                     STA $0282
                     LSR A
                     STA $0288 ; set HIBASE back to #$04
                     RTS


L8120                STA VERCK  ; store .A in the Load/Verify flag. $00 is Load. anything else is verify.
                     LDA FA     ; load pointer to current filename or disk command
                     CMP #$09 
                     BEQ L812C  ; Branch if .A is $09. 
                     CMP #$08; 
                     BNE L813F  ; Branch if .A isn't $08.
L812C                LDA VERCK  ; load the load/verify flag into .A.
                     BNE L813F ; if not zero, branch to $813F for verify instead of load
                     LDY #$00  ; LOAD, not verify.
                     LDX #$37  ; will be stored in R6510 to set processor port memory map.
                     LDA #$35  ; will be stored in R6510 to set processor port memory map.
                     JSR LDF27
                     LDX MEMUSS ; address for secondary address of 0 for load and verify from serial bus.
                     CMP #$24   ; is the filename '$' (loading directory)
                     BNE L8148  ; if not, branch to L8148
L813F                LDA #$F4   ; loading the directory, so fastload doesn't
                     PHA        ; apply. Set up the stack for $F4A7 return
                     LDA #$A6   ; to use normal C64 kernal LOAD routine
                     PHA
                     JMP LDF34  ; update R6510 and return (to $F4A7)
L8148                LDA SA ; load secondary address of current file into .A
                     BEQ L8150 ; branch if the secondary address is 0
                     LDA #$80
                     STA SA    ; store .A back to secondary address ($00)
L8150                LDA ICR  ; load interrupt control register.
                              ; Bit #0: 1 = Raster interrupt enabled.
                              ; Bit #1: 1 = Sprite-background collision interrupt enabled.
                              ; Bit #2: 1 = Sprite-sprite collision interrupt enabled.
                              ; Bit #3: 1 = Light pen interrupt enabled.
                     AND #$0F ; turn off the high 4 bits
                     ORA SA
                     STA SA
                     LDA #$00 
                     STA ICR  ; disable VIC-II interrupts
                     JSR LDFAB ; print "SEARCHING FOR <filename>"
                     JSR L81EE ; upload fastload code to 1541 and send filename
                               ; to be loaded
                     BCC L816B
                     LDA #$05
                     JMP L81C0


L816B                LDA SPENA ; sprite enable register
                     STA FIRT  ; temp storage for the sprite enable register 
                     LDA #$00
                     STA SPENA ; disable all sprites
                     JSR L9106
                     JSR L827A
                     JSR L8425
                     TAX
                     BNE L8186
                     SEC
                     LDA #$04
                     BCS L81C0
L8186                PHA
                     JSR LDFB1   ; print "LOADING" message
                     PLA
                     TAX
                     JSR L8425
                     STA LDADDR
                     JSR L8425
                     STA LDADDR+1
                     DEX
                     DEX
                     BIT SA
                     BMI L81A4
                     LDA MEMUSS
                     STA LDADDR
                     LDA MEMUSS+1
                     STA LDADDR+1
L81A4                JSR L8425
                     LDY #$00
                     STA (LDADDR),Y   ; stores in c64 RAM what it's reading from the 1541
                     INC LDADDR
                     BNE L81B1
                     INC LDADDR+1
L81B1                DEX
                     BNE L81A4
                     JSR L8558
                     JSR L8425
                     TAX
                     BNE L81A4
                     LDA #$40
                     CLC
L81C0                PHA
                     LDA FIRT
                     STA SPENA
                     PHP
                     JSR L80C6
                     LDA CNTDN
                     PHA
                     LDA #$40
                     STA R2D2
                     STA C3P0
                     JSR LDF5E
                     PLA
                     STA CNTDN
                     PLP
                     PLA
                     STA STATUS
                     LDA SA
                     STA ICR
                     LDA #$60
                     STA SA
                     LDX LDADDR
                     JMP LDF46
L81EE                JSR SENDMW
                     BCS L8200
                     LDY #$00
L81F5                LDA L9124,Y  ; additional code sent to the drive immediately after the M-W and M-E.

                     JSR L8290    ; routine to send a byte to the 1541
                     INY
                     BNE L81F5
                     CLC
                     RTS


L8200                SEC
                     RTS

; sends the M-W command to the 1541 and uploads the drive code.
SENDMW               LDX #$00   ; $8202 in the fastload cartridge
L8204                LDA D2PRA  ; load VIA 2 Port A register to .A ($97 = %10010111)
                                ; Port A, serial bus access. Bits:
                                ;
                                ; Bits #0-#1: VIC bank. Values:
                                ; %00, 0: Bank #3, $C000-$FFFF, 49152-65535.
                                ; %01, 1: Bank #2, $8000-$BFFF, 32768-49151.
                                ; %10, 2: Bank #1, $4000-$7FFF, 16384-32767.
                                ; %11, 3: Bank #0, $0000-$3FFF, 0-16383.
                                ;
                                ; on boot, 11, so Bank #0, $0000-$3FFF, 0-16383.
                                ;
                                ; Bit #2: RS232 TXD line, output bit.
                                ; Bit #3: Serial bus ATN OUT; 0 = High; 1 = Low.
                                ; Bit #4: Serial bus CLOCK OUT; 0 = High; 1 = Low.
                                ; Bit #5: Serial bus DATA OUT; 0 = High; 1 = Low.
                                ; Bit #6: Serial bus CLOCK IN; 0 = Low; 1 = High.
                                ; Bit #7: Serial bus DATA IN; 0 = Low; 1 = High.
                                ;
                                ; Bit #2 = 1, TXD output bit
                                ; Bit #3 = 0. ATN OUT   = High
                                ; Bit #4 = 1. CLOCK OUT = Low
                                ; Bit #5 = 0. DATA OUT  = High
                                ; Bit #6 = 0. CLOCK IN  = Low
                                ; Bit #7 = 1. DATA IN   = High
                     STA STATUS ; Store .A ($97) in STATUS
                                ; Bit #0: Transfer direction during which the timeout occured; 0 = Input; 1 = Output.
                                ; Bit #1: 1 = Timeout occurred.
                                ; Bit #4: 1 = VERIFY error occurred (only during VERIFY) byte read from device did not match memory.
                                ; Bit #6: 1 = End of file has been reached.
                                ; Bit #7: 1 = Device is not present.
                     ASL A      ; $97 = %10010111 becomes $2E = %00101110
                     ASL A      ; $2E = %00101110 becomes $5C = %01011100
                     EOR STATUS ;     %10010111 ($97)
                                ; EOR %01011100 ($5C)
                                ;   = %11001011 ($CB)
                     EOR #$C0   ; EOR %11000000 ($C0) 
                                ;   = %00001011 ($0B)
                     AND #$C0   ; AND %11000000 ($C0)
                                ;   = %00000000 ($00)
                     BEQ L821C  ; Branch if result is 0 so it will branch on first call.
                     DEY
                     BNE L8204
                     DEX
                     BNE L8204
                     JMP L8200
; This code was heavily modified for relocation and does not accurately
; represent the original Fastload disassembly. There was one routine here
; similar to SNDCHNK1 that was looped through three times to send three
; M-W commands to the 1541. The code relied heavily on address calculations
; to provide the 1541 with load addresses in the M-W command syntax.
; Relocating the code broke all of that address math, so I rewrote this
; to make it not rely on such.
L821C                LDA CNTDN 
                     PHA
                     JSR L841C  ; send LISTEN command to the 1541
                     SEC
                     LDA STATUS
                     BEQ DRVUPLD
                     JMP L826F
; The M-W command sent by Fastload to the 1541 stores the first chunk
; at $0180 on the 1541's stack. DRVUPLD will contain the low order byte
; of the 1541 start address.
DRVUPLD              LDA #$80 
                     STA DRVLD
                     LDA #<MW1 ; M-W chunk 1 load address
                     LDX #>MW1
                     STA LDADDR
                     STX LDADDR+1
L822F                JSR L82CD       ; send the actual M-W string
                     LDY #$00
SNDCHNK1             LDA (LDADDR),Y  ; loads the drive code
                     JSR IECSND      ; and sends it to the drive
                     INY             ; It does this $19 (byte count) times
                     CPY #$19
                     BNE SNDCHNK1
                     LDA #$0D        ; send a literal $0D after the data chunk
                     JSR IECSND
                     JSR LDF5E     ; send UNLISTEN
                     JSR L841C     ; send LISTEN
                     LDA #$99      ; 1541 load addr for 2nd M-W chunk is $0199
                     STA DRVLD
                     LDA #<MW2
                     LDX #>MW2
                     STA LDADDR
                     STX LDADDR+1
                     JSR L82CD       ; send the actual M-W string
                     LDY #$00
SNDCHNK2             LDA (LDADDR),Y  ; loads the drive code
                     JSR IECSND      ; and sends it to the drive
                     INY             ; It does this $19 (byte count) times
                     CPY #$19
                     BNE SNDCHNK2
                     LDA #$0D        ; send a literal $0D after the data chunk
                     JSR IECSND
                     JSR LDF5E     ; send UNLISTEN
                     JSR L841C     ; send LISTEN
                     LDA #$B2      ; 1541 load addr for 3rd M-W chunk is $01B2
                     STA DRVLD
                     LDA #<MW3
                     LDX #>MW3
                     STA LDADDR
                     STX LDADDR+1
                     JSR L82CD       ; send the actual M-W string
                     LDY #$00
SNDCHNK3             LDA (LDADDR),Y  ; loads the drive code
                     JSR IECSND      ; and sends it to the drive
                     INY             ; It does this $19 (byte count) times
                     CPY #$19
                     BNE SNDCHNK3
                     LDA #$0D        ; send a literal $0D after the data chunk
                     JSR IECSND
                     JSR LDF5E     ; send UNLISTEN
                     JSR L841C     ; send LISTEN
                     JSR L840E     ; send M-E command to begin execution on the
                                   ; 1541
                     JSR LDF5E     ; send UNLISTEN
L8262                BIT D2PRA
                     BVS L8262
                     LDA D2PRA
                     ORA #$20    ; set bit 5 (DATA OUT) to 1 = Low
                     STA D2PRA
L826F                PLA
                     STA CNTDN
                     RTS

L8273                LDA FA      ; load device num of the current file ($08-$0B)
                     ORA #$20    ; %00100000 - turn on bit 5
                                 ; Turns $08 into $28. $2x is the LISTEN
                                 ; command in IEC protocol, so $28 is 
                                 ; "LISTEN, Device 8" on the wire)
                     JMP LDF54

; sends the length of the filename and filename to the 1541
L827A                LDA FNLEN ; filename length
                     TAY
                     JMP L8287

L8280                LDA #$35
                     LDX #$37
                     JSR LDF27 ; grabs the filename from BASIC
L8287                JSR L8290 ; send one byte to the 1541
                     DEY
                     BPL L8280
                     JMP L8558
L8290                STA STATUS   ; STATUS is used as a sending byte buffer.
                     JSR L82A9 ; send 2 bits of STATUS to the 1541
                     JSR L82A9 ; send 2 bits of STATUS to the 1541
                     JSR L82A9 ; send 2 bits of STATUS to the 1541
                     JSR L82A9 ; send 2 bits of STATUS to the 1541
                     LDA D2PRA
                     AND #$0F  ; set CLOCK OUT, DATA OUT, CLOCK IN, and
                               ; DATA IN to 0 = High.
                     ORA #$20  ; set bit 5 (DATA OUT) to 1 = Low
                     STA D2PRA
                     RTS

; send two bits of data to the 1541. This is called 4 times to send one byte
; with the value of the byte to send in STATUS.
L82A9                LDA D2PRA  ; load VIA 2 Port A register to .A ($67 = %01100111)
                                ; Port A, serial bus access. Bits:
                                ;
                                ; Bits #0-#1: VIC bank. Values:
                                ; %00, 0: Bank #3, $C000-$FFFF, 49152-65535.
                                ; %01, 1: Bank #2, $8000-$BFFF, 32768-49151.
                                ; %10, 2: Bank #1, $4000-$7FFF, 16384-32767.
                                ; %11, 3: Bank #0, $0000-$3FFF, 0-16383.
                                ;
                                ; This run is 11, so Bank #0, $0000-$3FFF, 0-16383.
                                ;
                                ; Bit #2: RS232 TXD line, output bit.
                                ; Bit #3: Serial bus ATN OUT; 0 = High; 1 = Low.
                                ; Bit #4: Serial bus CLOCK OUT; 0 = High; 1 = Low.
                                ; Bit #5: Serial bus DATA OUT; 0 = High; 1 = Low.
                                ; Bit #6: Serial bus CLOCK IN; 0 = Low; 1 = High.
                                ; Bit #7: Serial bus DATA IN; 0 = Low; 1 = High.
                                ;
                                ; Bit #2 = 1, TXD output bit
                                ; Bit #3 = 0. ATN OUT   = High
                                ; Bit #4 = 0. CLOCK OUT = High
                                ; Bit #5 = 1. DATA OUT  = Low
                                ; Bit #6 = 1. CLOCK IN  = High
                                ; Bit #7 = 0. DATA IN   = Low
                     AND #$0F   ;      %01100111
                                ;  AND %00001111
                                ;    = %00000111 = $07
                     ORA #$10   ;  ORA %00010000
                                ;    = %00010111 = $17
                                ; state before sending a byte is %00010111
                                ; Bit #3 = 0. ATN OUT   = High
                                ; Bit #4 = 1. CLOCK OUT = Low
                                ; Bit #5 = 0. DATA OUT  = High
                                ; Bit #6 = 0. CLOCK IN  = Low
                                ; Bit #7 = 0. DATA IN   = Low
                     LSR STATUS ; shift off the low bit of the byte to send to the drive
                     BCC L82B6  ; If we shifted off a 0 bit, branch to L82B6
                     ORA #$20   ; if we shifted off a 1 bit (%00100000) pin 5, DATOUT = 1 = Low
L82B6                STA D2PRA  ; Store the bits to the VIA 2 port register
                                ; 
                                ; For even bits: (0,2,4,6) 
                                ; CLOCK OUT is Low
                                ; To send a 0 bit = %00010111   ($17)
                                ; Bit #3 = 0. ATN OUT   = High
                                ; Bit #4 = 1. CLOCK OUT = Low
                                ; Bit #5 = 0. DATA OUT  = High
                                ; Bit #6 = 0. CLOCK IN  = Low
                                ; Bit #7 = 0. DATA IN   = Low
                                ;
                                ; To send a 1 bit = %00110111   ($37)
                                ; Bit #3 = 0. ATN OUT   = High
                                ; Bit #4 = 1. CLOCK OUT = Low
                                ; Bit #5 = 1. DATA OUT  = Low
                                ; Bit #6 = 0. CLOCK IN  = Low
                                ; Bit #7 = 0. DATA IN   = Low
                     NOP
                     NOP
                     NOP        ; hold the PRA pins for 5 cpu cycles
                     NOP
                     NOP
                     AND #$0F ; (%00001111)
                                ; Bit #4 = 0. CLOCK OUT = High
                                ; Bit #5 = 0. DATA OUT  = High
                                ; Bit #6 = 0. CLOCK IN  = Low
                                ; Bit #7 = 0. DATA IN   = Low
                     LSR STATUS ; shift off the low bit of the byte to send to the drive
                     BCC L82C6  ; If we shifted off a 0 bit, branch to L82C6
                     ORA #$20   ; If we shifted off a 1 bit (%00100000) pin 5, DATOUT = 1 = Low
L82C6                STA D2PRA  ; Store the bits to the VIA 2 port register
                                ;
                                ; For odd bits: (1,3,5,7)
                                ; CLOCK OUT is High
                                ; To send a 0 bit = %00000111   ($07)
                                ; Bit #3 = 0. ATN OUT   = High
                                ; Bit #4 = 0. CLOCK OUT = High
                                ; Bit #5 = 0. DATA OUT  = High
                                ; Bit #6 = 0. CLOCK IN  = Low
                                ; Bit #7 = 0. DATA IN   = Low
                                ;
                                ; To send a 1 bit = %00100111   ($27)
                                ; Bit #3 = 0. ATN OUT   = High
                                ; Bit #4 = 0. CLOCK OUT = High
                                ; Bit #5 = 1. DATA OUT  = Low
                                ; Bit #6 = 0. CLOCK IN  = Low
                                ; Bit #7 = 0. DATA IN   = Low

                     NOP
                     NOP        ; hold the PRA pins for 3 cpu cycles
                     NOP
                     RTS

; send the M-W DOS command
L82CD                LDA #$4D    ; M
                     JSR IECSND 
                     LDA #$2D    ; -
                     JSR IECSND
                     LDA #$57    ; W
                     JSR IECSND
; the original code calculated the drive load address relative to the load
; address on the c64. This made relocation difficult, so I rewrote this
; routine to grab the drive load address from DRVLD. The high byte is always
; $01 so that's hard coded. 
                     LDA DRVLD
                     JSR IECSND
                     LDA #$01   
                     CLC
                     JSR IECSND
                     LDA #$19    ; how many bytes we're sending in this chunk.
                     JMP IECSND

* = $C300
; lookup table indexed by raster line. I put this at $C300 intentionally
; because it was at $8300 in the original code and there are indexed
; lookups into this table. It made relocation easier to keep everything
; at the same offset. This is used to avoid acking a byte received from
; the 1541 before a badline
.byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
.byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
.byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
.byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
.byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
.byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00
.byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00

; Memory Execute command sent to the 1541 after the
; three Memory Write chunks of 25 bytes each have been sent.
; M-E $01A9 (begins execution on the 1541's stack at $01A9
L8408    .byte       $4D,$2D,$45,$A9,$01,$0D 
L840E                LDY #$00
L8410                LDA L8408,Y
                     JSR IECSND
                     INY
                     CPY #$06
                     BNE L8410
                     RTS

L841C                LDA #$00
                     STA STATUS
                     LDX #$6F    ; for sending open #15 command to the 1541
                     JMP L8273

; this is the routine that reads a byte from the 1541
L8425                LDY RASTER
                     LDA (C3P0),Y ; reads from the table at $C300. Will
                     BEQ L8425    ; always read either $00 or $0f.
                                  ; this appears to be in place to avoid
                                  ; badlines. If the C64 acks a byte, then 
                                  ; loses cpu cycles, it will miss data
                                  ; coming from the 1541.
                     AND D2PRA    ; .A will always contain $0F here
                     STA D2PRA    ; turn off the high 4 bits of D2PRA
                                  ; CLOCK OUT = High
                                  ; DATA OUT  = High
                                  ; CLOCK IN  = Low
                                  ; DATA IN   = Low
                     ORA #$20     ; set bit 5 in .A
                     TAY 
                     NOP          ; hold CLKOUT and DATOUT high
                     NOP          ; for 4 cycles
                     NOP
                     NOP
                     LDA D2PRA  
                     LSR A        ; shift off bits 0 and 1
                     LSR A      
                     NOP          
                     EOR D2PRA    ;     %00010001 ($11)
                                  ; EOR %01000111 ($47 in D2PRA)
                                  ;     ---------
                                  ;     %01010110 ($56)      
                     LSR A        ; %01010110 -> %00101011 ($2B)
                     LSR A        ; %00101011 -> %00010101 ($15)
                     NOP
                     EOR D2PRA    ;     %00010101 ($15)
                                  ; EOR %01000111 ($47 in D2PRA)
                                  ;     ---------
                                  ;     %01010010 (52) 
                     LSR A        ; %01010010 -> %00101001 ($29)
                     LSR A        ; %00101001 -> %00010100 ($14)
                     NOP
                     EOR D2PRA    ;     %00010100 ($14)
                                  ; EOR %01000111 ($47 in D2PRA)
                                  ;     ---------
                                  ;     %01010011 ($53)
                     STY D2PRA    
                     EOR R2D2     ;     %01010011 ($53)
                                  ; EOR %11111001 ($F9 - value read from $A3)
                                  ;     ---------
                                  ;     %10101010 ($AA)
                     TAY  ; A:AA X:37 Y:27.  after executing A:AA X:37 Y:AA
                     LDA L8458,Y
                     RTS

; this is used as a lookup table to convert data read from the 1541
; Each byte is sent over the wire two bits at a time:
; bits 5 and 7, bits 4 and 6, bits 1 and 3, and bits 0 and 2.
; this table is used instead of doing bitwise manipulation to reorder
; the bits
L8458
.byte $00,$80,$20,$a0,$40,$c0,$60,$e0
.byte $10,$90,$30,$b0,$50,$d0,$70,$f0
.byte $08,$88,$28,$a8,$48,$c8,$68,$e8
.byte $18,$98,$38,$b8,$58,$d8,$78,$f8
.byte $02,$82,$22,$a2,$42,$c2,$62,$e2
.byte $12,$92,$32,$b2,$52,$d2,$72,$f2
.byte $0a,$8a,$2a,$aa,$4a,$ca,$6a,$ea
.byte $1a,$9a,$3a,$ba,$5a,$da,$7a,$fa
.byte $04,$84,$24,$a4,$44,$c4,$64,$e4
.byte $14,$94,$34,$b4,$54,$d4,$74,$f4
.byte $0c,$8c,$2c,$ac,$4c,$cc,$6c,$ec
.byte $1c,$9c,$3c,$bc,$5c,$dc,$7c,$fc
.byte $06,$86,$26,$a6,$46,$c6,$66,$e6
.byte $16,$96,$36,$b6,$56,$d6,$76,$f6
.byte $0e,$8e,$2e,$ae,$4e,$ce,$6e,$ee
.byte $1e,$9e,$3e,$be,$5e,$de,$7e,$fe
.byte $01,$81,$21,$a1,$41,$c1,$61,$e1
.byte $11,$91,$31,$b1,$51,$d1,$71,$f1
.byte $09,$89,$29,$a9,$49,$c9,$69,$e9
.byte $19,$99,$39,$b9,$59,$d9,$79,$f9
.byte $03,$83,$23,$a3,$43,$c3,$63,$e3
.byte $13,$93,$33,$b3,$53,$d3,$73,$f3
.byte $0b,$8b,$2b,$ab,$4b,$cb,$6b,$eb
.byte $1b,$9b,$3b,$bb,$5b,$db,$7b,$fb
.byte $05,$85,$25,$a5,$45,$c5,$65,$e5
.byte $15,$95,$35,$b5,$55,$d5,$75,$f5
.byte $0d,$8d,$2d,$ad,$4d,$cd,$6d,$ed
.byte $1d,$9d,$3d,$bd,$5d,$dd,$7d,$fd
.byte $07,$87,$27,$a7,$47,$c7,$67,$e7
.byte $17,$97,$37,$b7,$57,$d7,$77,$f7
.byte $0f,$8f,$2f,$af,$4f,$cf,$6f,$ef
.byte $1f,$9f,$3f,$bf,$5f,$df,$7f,$ff


; JMP here from $828D immediately after sending the filename to the 1541
L8558                LDA D2PRA
                     AND #$0F  ; mask off the high nybble
                     ORA #$20  ; set bit 5 (DATA OUT) to 1 = Low
                     STA D2PRA 
                     JSR L8571
                     LDA #$40
L8567                BIT D2PRA
                     BEQ L8567 ; wait for DATIN to go high
                     LDA #$7F
L856E                LSR A
                     BCS L856E
L8571                RTS

L9106                LDA SCROLY ; default is $1b in scroll register
                     AND #$07   ; turn off bits 3-7
                                ;AND %00000111 ($07)
                                ;    ---------
                                ;    %00000011 ($03)
                     EOR #$07   ;EOR %00000111 ($07)
                                ;    ---------
                                ;    %00000100 ($04)
                     STA C3P0   ; stores $04 at $0094
                     LDA #$C3
                     STA BSOUR  ; will result in an effective address of
                                ; $C304 for loading using indirect .Y
                                ; addressing for the table at $C300
                     LDA D2PRA
                     LSR A     ; shift off the VIC bank bits
                     LSR A     ; so the TXD output bit is at 0
                               ; and ATN OUT is at bit 1
                     AND #$03  ; turn off bits 2-7
                               ;     %00000001
                     EOR D2PRA ; set the complement of the CIA serial register
                     AND #$0F  ; turn off the bits in the high nybble
                     EOR #$FF  ; EOR %11111111
                               ;     ---------
                               ;     %11111001 ($F9)
                     STA R2D2  ; stores $F9
                     RTS

; this is more drive code that's uploaded after the three M-W chunks.
; This is uploaded using Fastload protocol to the $0500 buffer on the 1541
L9124  
.byte $20,$80,$01,$aa,$86,$a3,$38,$b0
.byte $06,$20,$80,$01,$9d,$00,$02,$ca
.byte $10,$f7,$a9,$08,$8d,$00,$18,$ad
.byte $00,$1c,$09,$08,$8d,$00,$1c,$a9
.byte $00,$85,$83,$a9,$f0,$85,$84,$58
.byte $a9,$e4,$8d,$4f,$02,$20,$46,$c1
.byte $a0,$00,$b1,$30,$99,$00,$04,$c8
.byte $d0,$f8,$a9,$01,$85,$1c,$78,$a9
.byte $00,$f0,$3e,$a9,$08,$8d,$00,$18
.byte $ad,$07,$1c,$a0,$01,$8c,$05,$1c
.byte $8d,$07,$1c,$c8,$84,$8b,$58,$a9
.byte $80,$85,$01,$a5,$01,$30,$fc,$c9
.byte $01,$f0,$1d,$c6,$8b,$30,$14,$d0
.byte $04,$a9,$c0,$85,$01,$a5,$16,$85
.byte $12,$a5,$17,$85,$13,$a5,$01,$30
.byte $fc,$10,$db,$a2,$02,$4c,$0a,$e6
.byte $78,$ae,$01,$04,$86,$09,$ad,$00
.byte $04,$85,$08,$f0,$02,$a2,$ff,$86
.byte $15,$ca,$8e,$01,$04,$a0,$00,$a9
.byte $00,$8d,$00,$18,$c8,$b9,$00,$04
.byte $4a,$4a,$4a,$4a,$aa,$a9,$01,$8d
.byte $00,$18,$2c,$00,$18,$d0,$fb,$8e
.byte $00,$18,$8a,$0a,$29,$0f,$8d,$00
.byte $18,$b9,$00,$04,$29,$0f,$8d,$00
.byte $18,$0a,$29,$0f,$ea,$8d,$00,$18
.byte $c4,$15,$d0,$d0,$ad,$00,$04,$f0
.byte $03,$4c,$43,$05,$8d,$00,$18,$a2
.byte $76,$bd,$4b,$eb,$9d,$00,$04,$ca
.byte $10,$f7,$a9,$60,$8d,$77,$04,$20
.byte $00,$04,$4c,$e7,$eb,$20,$d7,$05  
.byte $85,$08,$20,$d7,$05,$85,$09,$20
.byte $d7,$05,$85,$8c,$c9,$01,$d0,$0b


L946A                TYA
                     JSR L95FE
                     TXA
                     JMP L95FE

L95FE                PHA
                     LSR A
                     LSR A
                     LSR A
                     LSR A
                     JSR L9609
                     PLA
                     AND #$0F
L9609                CMP #$0A
                     SED
                     ADC #$30
                     CLD
                     JMP LDF89

LC000     ; FASTLOAD greeting text
.byte $0d,$46,$41,$53,$54,$4c,$4f,$41,$44,$8d

; this routine is what the Fastload cartridge used to make
; the cartridge at $8000 visible. It's not necessary when
; running from $C000. I left it here and commented out rather
; than updating all the calling code.
LDF15                SEI
;                     PHP
;                     PHA
;LDF1A                INC $DE00,X
;                     INC $DE00,X
;                     SBC #$01
;                     BCS LDF1A
;                     PLA
;                     PLP
                     RTS


; this routine gloms a byte of the filename from the load
; command from BASIC,
; .Y is indexed into the byte buffer
; value stored in .A upon return
LDF27                STA R6510 ; store .A = $35 in the processor port.
                               ; $35 (%00110101)
                               ; Bits 0-2 = 101
                               ; x01 = RAM visible at $1000-$BFFF;
                               ;       Kernal ROM visible at $E000-$FFFF
                               ; 1xx = I/O area visible at $D000-$DFFF
                     LDA (LA),Y
                     STX R6510 ; store .X = $37 in the processor port.
                               ; $37 (%00110111)
                               ; Bits 0-2 = 111
                               ; x11 = BASIC ROM visible at $A000-$BFFF.
                               ;       Kernal ROM visible at $E000-$FFFF
                               ; 1xx = I/O area visible at $D000-$DFFF
                     RTS

; this is the kernal entry point for the LOAD routine
; (indirect JMP from $0330).
; It's at $DF2E in the Fastload cartridge
LOAD                 JMP L8120

LDF34                LDA CNTDN
                     STA R6510
LDF38                RTS


LDF46                JSR LDF34
                     LDA STATUS
                     LDY LDADDR+1
                     RTS

IECSND               JSR IECOUT     ; $DF4E in the cartridge code
                     JMP LDF15

LDF54                JSR LIST1 ; skips the first two instructions of LISTN,
                               ; which are to JSR to RSP232 (turn off NMI)
                               ; and set a LISTEN address (i.e. turn $08
                               ; into $28) which happened in the caller here
                               ; in L8273
                     TXA       ; .X contains the secondary address to
                               ; the serial bus
                     JSR LSTNSA; send the secondary address to ths serial bus.
                               ; $6F = $60 (Open Channel/data IEC command)
                               ; + $0F (15 decimal)
                               ; this opens channel 15
                     JMP LDF15

LDF5E                JSR UNLSTN ; send UNLISTEN command to 1541
                     JMP LDF15

LDF64                JSR $E453 ; copy BASIC vectors to RAM
                     JMP LDF15

LDF70                JSR LDF38
                     JMP $A490 ; execute block in the MAIN routine

LDF76                CLI
                     JSR IFLIN ; input a line from keyboard
                     JMP LDF15

LDF89                JSR $E716 ; output a petscii char to the screen
                     JMP LDF15

LDFAB                JSR LUKING ; print "SEARCHING" LOAD response 
                     JMP LDF15

LDFB1                JSR LODING ; print "LOADING" LOAD response
                     JMP LDF15

MW1  ; M-W drive upload code chunk 1
.byte $a0,$04,$a9,$04,$2c,$00,$18,$30
.byte $1d,$f0,$f9,$ad,$00,$18,$4a,$66
.byte $14,$a9,$04,$2c,$00,$18,$30,$0e
.byte $d0            
MW2  ; M-W drive upload code chunk 2
.byte $f9,$ad,$00,$18,$4a,$66,$14,$88
.byte $d0,$df,$a5,$14,$60,$68,$68,$60
.byte $78,$a9,$08,$8d,$00,$18,$a9,$01
.byte $2c            
MW3  ; M-W drive upload code chunk 3
.byte $00,$18,$f0,$fb,$8d,$00,$18,$a2
.byte $00,$20,$80,$01,$9d,$00,$05,$e8
.byte $d0,$f7,$e8,$86,$1c,$4c,$00,$05
.byte $78            
