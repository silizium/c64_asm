;*****************************************************************************
; Epyx Fastload drive execution code that is uploaded to the 1541 
; by the Epyx Kernal code running on the C64
;
; Disassembled February, 2024 by Dave McMurtrie <dave@commodore.international>
; This code has not been formatted for assembly, as it is uploaded
; dynamically by the C64 when the LOAD vector is executed. There would be
; no utility in assembling this code as it is.
;
; All credit goes to Scott Nelson, the original author of Epyx Fastload
;*****************************************************************************
; 1541 I/O DEFINITIONS SERIAL I/O 6522 ($1800-$180F)
; DATA PORT B - Serial data I/O
; BITS FOR SERIAL HANDSHAKE
; Bit 0 - $01 Data in line    0 = Low; 1 = High
; Bit 1 - $02 Data out line   1 = Low; 0 = High
; Bit 2 - $04 Clock in line   0 = Low; 1 = High
; Bit 3 - $08 Clock out line  1 = Low; 0 = High
; Bit 4 - $10 Attention acknowledge line 
; Bit 7 - $80 Attention in line 0 = Low; 1 = High
;
; 1541 stack lives at $0104-$01FF, so the first chunks of code
; live on the stack 
0180   A0 04      L0180     LDY #$04
0182   A9 04      L0182     LDA #$04
0184   2C 00 18   L0184     BIT $1800      ; check if ATN is 1
0187   30 1D                BMI L01A6      ; N flag is set so ATN is 1 (low). Branch to L01A6. 
0189   F0 F9                BEQ L0184      ; bit 2 ($04) CLOCK IN was 1 (low). Go back and wait
018B   AD 00 18             LDA $1800
018E   4A                   LSR A
018F   66 14                ROR $14
0191   A9 04                LDA #$04
0193   2C 00 18   L0193     BIT $1800
0196   30 0E                BMI L01A6
0198   D0 F9                BNE L0193
019A   AD 00 18             LDA $1800
019D   4A                   LSR A
019E   66 14                ROR $14
01A0   88                   DEY
01A1   D0 DF                BNE L0182
01A3   A5 14                LDA $14
01A5   60                   RTS
01A6   68         L01A6     PLA
01A7   68                   PLA
01A8   60                   RTS
01A9   78                   SEI      ; M-E begins execution here.
01AA   A9 08                LDA #%00001000
01AC   8D 00 18             STA $1800 ; set CLKOUT to 1 = Low
01AF   A9 01                LDA #$01
01B1   2C 00 18   L01B1     BIT $1800 ; check if DATIN is 1 = low
                                      ; (c64 pulls DATIN low when ready)
01B4   F0 FB                BEQ L01B1 ; it's not. go back and wait.
01B6   8D 00 18             STA $1800 ; set DATIN to 1 = low
01B9   A2 00                LDX #$00  ; Load 256 bytes from c64 to $0500
01BB   20 80 01   L01BB     JSR L0180
01BE   9D 00 05             STA $0500,X
01C1   E8                   INX
01C2   D0 F7                BNE L01BB
01C4   E8                   INX
01C5   86 1C                STX $1C
01C7   4C 00 05             JMP $0500 ; as soon as the rest of the code is loaded,
                                      ; JMP to it and begin executing.
01CA   78                   SEI
                            .END

; The following is loaded to the drive using Fastload protocol
; (see $01BE above).
; After this 256 bytes of code is loaded to $0500, the first thing it does is
; call back to $0180 to read the filename from the C64
                            * = $0500
0500   20 80 01             JSR $0180   ; grab the filename length from the c64
0503   AA                   TAX
0504   86 A3                STX $A3     ; store it in $A3 (misusing pointer to input buffer)
0506   38                   SEC
0507   B0 06                BCS L050F
0509   20 80 01   L0509     JSR $0180   ; grab each byte of the filename to load
050C   9D 00 02             STA $0200,X ; and store it in the buffer at $0200
050F   CA         L050F     DEX
0510   10 F7                BPL L0509
0512   A9 08                LDA #%00001000 ; CLKOUT = 1 = Low. All other lines released high.
0514   8D 00 18             STA $1800
; $1C00 - $1C0F
; VIA #2; drive control
; Bits #0-#1: Head step direction.
;   Decrease value (%00-%11-%10-%01-%00...) to move head downwards;
;   increase value (%00-%01-%10-%11-%00...) to move head upwards.
;
;   Bit #2: Motor control; 0 = Off; 1 = On.
;
;   Bit #3: LED control; 0 = Off; 1 = On.
;
;   Bit #4: Write protect photocell status;
;     0 = Write protect tab covered, disk protected
;     1 = Tab uncovered, disk not protected.
;
;   Bits #5-#6: Data density;
;     %00 = Lowest;
;     %11 = Highest.
;
;   Bit #7: 
;     0 = SYNC marks are being currently read from disk;
;     1 = Data bytes are being read.
0517   AD 00 1C             LDA $1C00
051A   09 08                ORA #$08  ; Turn on 1541 drive LED
051C   8D 00 1C             STA $1C00
051F   A9 00                LDA #$00
0521   85 83                STA $83   ; Current secondary address = $00
                                      ; (indicates a LOAD)
0523   A9 F0                LDA #$F0
0525   85 84                STA $84   ; Original secondary address = $F0
0527   58                   CLI
0528   A9 E4                LDA #%11100100
052A   8D 4F 02             STA $024F ; Buffer #2 is being used.
                                      ; Error message buffer being used.
052D   20 46 C1             JSR $C146 ; call PARSXQ to parse and execute
                                      ; the current command
0530   A0 00                LDY #$00
0532   B1 30      L0532     LDA ($30),Y ; copy 256 bytes from the read buffer
                                        ; to $0400
0534   99 00 04             STA $0400,Y
0537   C8                   INY
0538   D0 F8                BNE L0532
053A   A9 01                LDA #$01
053C   85 1C                STA $1C ; store 1 in unit 0 disk change indicator
                                    ; status of write-protect photocell has
                                    ; changed
053E   78                   SEI
053F   A9 00                LDA #$00
0541   F0 3E                BEQ L0581
0543   A9 08                LDA #$08
0545   8D 00 18             STA $1800
0548   AD 07 1C             LDA $1C07
054B   A0 01                LDY #$01
054D   8C 05 1C             STY $1C05
0550   8D 07 1C             STA $1C07
0553   C8                   INY
0554   84 8B                STY $8B
0556   58         L0556     CLI
0557   A9 80                LDA #$80
0559   85 01                STA $01
055B   A5 01      L055B     LDA $01
055D   30 FC                BMI L055B
055F   C9 01                CMP #$01
0561   F0 1D                BEQ L0580
0563   C6 8B                DEC $8B
0565   30 14                BMI L057B
0567   D0 04                BNE L056D
0569   A9 C0                LDA #$C0
056B   85 01                STA $01
056D   A5 16      L056D     LDA $16
056F   85 12                STA $12
0571   A5 17                LDA $17
0573   85 13                STA $13
0575   A5 01      L0575     LDA $01
0577   30 FC                BMI L0575
0579   10 DB                BPL L0556
057B   A2 02      L057B     LDX #$02
057D   4C 0A E6             JMP $E60A
0580   78         L0580     SEI
0581   AE 01 04   L0581     LDX $0401 ; $0400 and $0401 seems to be the file size + 1.
                                      ; the prg data begins at $0402 with the low byte
                                      ; and $0403 as the high byte of the load address
                                      ; Debugger show $00 and $12, respectively at $0400
                                      ; and $0401
0584   86 09                STX $09   ; store in buffer 1 track and sector reg.
0586   AD 00 04             LDA $0400 ; low byte of the load address
0589   85 08                STA $08   ; store in buffer 1 trk and sect regstr.
058B   F0 02                BEQ L058F ; if the low byte was 0, branch
058D   A2 FF                LDX #$FF
058F   86 15      L058F     STX $15   ; Store the filesize +1  at $15
0591   CA                   DEX       ; decrement for the actual file size
0592   8E 01 04             STX $0401 ; overwrite $0401 with the actual file size
0595   A0 00                LDY #$00
0597   A9 00                LDA #$00
0599   8D 00 18             STA $1800 ; release all lines high
059C   C8         L059C     INY
059D   B9 00 04             LDA $0400,Y ; load starting at $0401
05A0   4A                   LSR A  ; shift the low 4 bits off
05A1   4A                   LSR A
05A2   4A                   LSR A
05A3   4A                   LSR A
05A4   AA                   TAX
05A5   A9 01                LDA #$01
05A7   8D 00 18             STA $1800 ; XXX - bit 0 (DATIN) is an input. What does setting it do?
05AA   2C 00 18   L05AA     BIT $1800 ; wait for DATA IN to go high
05AD   D0 FB                BNE L05AA
05AF   8E 00 18             STX $1800 ; store the high nybble of the data byte
                                      ; in PRB.
                                      ; (the low 4 bits were shifted off above)
                                      ; This uses DATAOUT and CLKOUT
                                      ; (bits 1 and 3) to send
                                      ; the first two bits which are bits 5 & 7
                                      ; of the original byte
05B2   8A                   TXA     
05B3   0A                   ASL A     ; shift left. bit 0 gets shifted to bit 1
                                      ; (CLKOUT) and bit 2 gets shifted to 
                                      ; bit 3 (DATAOUT).
05B4   29 0F                AND #$0F  ; turn off the high 4 bits
05B6   8D 00 18             STA $1800 ; DATAOUT and CLKOUT to send bits 1 and 3 
                                      ; which were bits 4 & 6 of the original
                                      ; byte.
05B9   B9 00 04             LDA $0400,Y ; do the same for the low nybble
05BC   29 0F                AND #$0F    ; by masking off the 4 high bits
05BE   8D 00 18             STA $1800   ; and storing this in the VIA
                                        ; (send bits 1 and 3)
05C1   0A                   ASL A       ; shift left one bit
05C2   29 0F                AND #$0F    ; mask off the high nybble
05C4   EA                   NOP         ; wait an instruction
05C5   8D 00 18             STA $1800   ; send bits 0 and 2
05C8   C4 15                CPY $15     ; did we send the entire file?
05CA   D0 D0                BNE L059C   ; no -- go back and send another byte
05CC   AD 00 04             LDA $0400
05CF   F0 03                BEQ L05D4
05D1   4C 43 05             JMP L0543
05D4   8D 00 18   L05D4     STA $1800
05D7   A2 76      L05D7     LDX #$76
05D9   BD 4B EB   L05D9     LDA $EB4B,X
05DC   9D 00 04             STA $0400,X
05DF   CA                   DEX
05E0   10 F7                BPL L05D9
05E2   A9 60                LDA #$60
05E4   8D 77 04             STA $0477
05E7   20 00 04             JSR $0400
05EA   4C E7 EB             JMP $EBE7
05ED   20 D7 05             JSR L05D7
05F0   85 08                STA $08
05F2   20 D7 05             JSR L05D7
05F5   85 09                STA $09
05F7   20 D7 05             JSR L05D7
05FA   85 8C                STA $8C
05FC   C9 01                CMP #$01
05FE   D0 0B                BNE $060B
