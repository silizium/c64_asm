 ;====================================================== 
 ; Bit Counting 
 ;------------------------------------------------------ 
 ; This file contains various 6502 coded algorithms that 
 ; count the number of one bits in a byte value. 
 ; 
 ; The different CPU performance and memory usage 
 ; characteristics have been calculated for each method 
 ; to show the speed and space trade offs. 
 ; 
 ; If you have the space to spare than the 256 byte 
 ; lookup table is the fastest otherwise the in place 
 ; shift/add method is a good allrounder. 
 ; 
 ; These examples have been developed for use with 
 ; Michal Kowalski's 6502 emulator. 
 ; 
 ; If you can think of any other ways of calculating 
 ; this or speeding up these routines please let me 
 ; know. 
 ; 
 ; Compiled by Andrew Jacobs (BitWise) with additions 
 ; from members of the 6502.org forum. 
 ; 
 ; Thanks to Thowllly & dclxvi for code speed ups and 
 ; dclxvi for the in place shift/add method. 
 ;====================================================== 
 ; Revision History: 
 ; 2007-08-28 AJ First release. 
 ; 2007-08-30 AJ Included forum suggestions. 
 ;------------------------------------------------------ 
 
         .ORG $00 
 
 SCRATCH .DS  2                  ; Some scratch memory 
 
         .ORG $8000 
         .START $8000 
 
         JMP ByteAtATime         ; Jump to first example 
 
 ;====================================================== 
 ; Bit Counting Via a Lookup Table 
 ;------------------------------------------------------ 
 ; The fastest way of figuring out how many bits are set 
 ; in a byte is to use a precalculated table and index 
 ; into it using either X or Y. 
 ; 
 ; This method is so simple that you don't need to put 
 ; the code in a subroutine for reuse. 
 ; 
 ; The only downside to this is that it needs a whole 
 ; 256 byte page to hold the lookup table. 
 ; 
 ; Time: 6 cycles (+1 if data table crosses page) 
 ; Size: 256 bytes (for data) 
 
 ; Look up table of bit counts in the values $00-$FF 
 
 ByteBitCounts: 
         .BYTE 0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4 
         .BYTE 1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5 
         .BYTE 1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5 
         .BYTE 2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6 
         .BYTE 1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5 
         .BYTE 2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6 
         .BYTE 2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6 
         .BYTE 3,4,4,5,4,5,5,6,4,5,5,6,5,6,6,7 
         .BYTE 1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5 
         .BYTE 2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6 
         .BYTE 2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6 
         .BYTE 3,4,4,5,4,5,5,6,4,5,5,6,5,6,6,7 
         .BYTE 2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6 
         .BYTE 3,4,4,5,4,5,5,6,4,5,5,6,5,6,6,7 
         .BYTE 3,4,4,5,4,5,5,6,4,5,5,6,5,6,6,7 
         .BYTE 4,5,5,6,5,6,6,7,5,6,6,7,6,7,7,8 
 
 ;------------------------------------------------------ 
 
 ByteAtATime: 
         LDX #$54                ; Load value to lookup 
         LDA ByteBitCounts,X     ; and get its bit count 
 
         NOP                     ; A contains bit count 
 
 ; We can add together the bit counts of several bytes 
 ; to compute the total number of bits in larger values. 
 
         LDA #$12                ; Set up an example 
         STA SCRATCH+0           ; 16-bit value 
         LDA #$34 
         STA SCRATCH+1 
 
         CLC                     ; Clear carry 
         LDX SCRATCH+0           ; Fetch first data byte 
         LDA ByteBitCounts,X     ; bit count 
         LDX SCRATCH+1           ; And add in the next 
         ADC ByteBitCounts,X 
 
         NOP                     ; A has bit total count 
 
         JMP HalfTheDataTable    ; Jump to next method 
 
 ;====================================================== 
 ; Bit Counting With A Smaller Lookup Table 
 ;------------------------------------------------------ 
 ; We can half the size of the look up table by using 
 ; the fact that the bit count for a value V in the 
 ; range $80-$FF will be one more than that for V & $7F. 
 ; 
 ; Infact it doesn't matter which bit we use providing 
 ; we are left with an easy to access 7 bits afterwards. 
 ; 
 ; So if we move bit 0 into the carry using LSR and then 
 ; look up the bit count for bits 6 downto 0 and add the 
 ; carry back we get the right result. 
 ; 
 ; Time: 16 cycles (+1 if data table crosses page) 
 ; Size: 136 bytes (8  for code, 128 for data) 
 
 BitCountSeven: 
         LSR                     ; Put bit 0 into carry 
         TAX 
         LDA SevenBitCounts,X    ; Fetch the bit count 
         ADC #0                  ; Add in bit 7 
         RTS 
 
 ; Look up table of bit counts in the values $00-$7F 
 
 SevenBitCounts: 
         .BYTE 0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4 
         .BYTE 1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5 
         .BYTE 1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5 
         .BYTE 2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6 
         .BYTE 1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5 
         .BYTE 2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6 
         .BYTE 2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6 
         .BYTE 3,4,4,5,4,5,5,6,4,5,5,6,5,6,6,7 
 
 ;------------------------------------------------------ 
 
 HalfTheDataTable: 
         LDA #$54                ; Load a test value 
         JSR BitCountSeven       ; Calculate the count 
 
         NOP                     ; Result is in A 
 
         JMP NybbleAtATime       ; Jump to next method 
 
 ;====================================================== 
 ; Bit Counting With An Even Smaller Lookup Table 
 ;------------------------------------------------------ 
 ; If we are prepared to do a small amount of shifting 
 ; then we can reduce the data table to 16 bytes. 
 ; 
 ; This algorithm breaks the value into three parts. The 
 ; hi nybble is shifted down and placed in Y. The shifts 
 ; leave bit 3 of the value in the carry so only bits 
 ; 2 to 0 need to be extracted into X. The bit counts 
 ; for the X & Y values are looked up and added which 
 ; combines them with the bit in C. 
 ; 
 ; Time: 31 cycles (+2 if data table crosses page) 
 ; Size: 33 bytes (17  for code, 16 for data) 
 
 BitCountNybble: 
         TAX                     ; Save a copy of value 
         LSR                     ; Shift down hi nybble 
         LSR 
         LSR 
         LSR                     ; Leave <3> in C 
         TAY                     ; And save <7:4> in Y 
         TXA                     ; Recover value 
         AND #$07                ; Put out <2:0> in X 
         TAX                     ; And save in X 
         LDA NybbleBitCounts,Y   ; Fetch count for Y 
         ADC NybbleBitCounts,X   ; Add count for X & C 
         RTS 
 
 ; Look up table of bit counts in the values $00-$0F 
 
 NybbleBitCounts: 
         .BYTE 0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4 
 
 ;------------------------------------------------------ 
 
 NybbleAtATime: 
         LDA #$54                ; Load a test value 
         JSR BitCountNybble      ; Calculate the count 
 
         NOP                     ; Result is in A 
 
         JMP BitAtATime          ; Jump to next method 
 
 ;====================================================== 
 ; Bit Counting Using Shifts 
 ;------------------------------------------------------ 
 ; The smallest method for count bits shifts the value 
 ; left one bit at a time and counts each one bit that 
 ; is shifted out. 
 ; 
 ; If we use ASL to perform the shift then the value 
 ; will become zero after at most eight iterations. By 
 ; looking for see when the value has reached zero we 
 ; can stop iterating as soon as there are no bits left 
 ; to shift out. 
 ; 
 ; Time: 18 to 76 cycles (depending on the value) 
 ; Size: 10 bytes 
 
 BitCountIterative: 
         LDX #$FF                ; Set count to -1 
 .Incr:  INX                     ; Add one to count 
 .Loop:  ASL                     ; Shift by one bit 
         BCS .Incr               ; Count one bits 
         BNE .Loop               ; Repeat till zero 
         TXA                     ; Move count to A 
         RTS 
 
 ;------------------------------------------------------ 
 
 BitAtATime: 
         LDA #$54                ; Load a test value 
         JSR BitCountIterative   ; Calculate the count 
 
         NOP                     ; Result is in A 
 
         JMP ShiftAndAdd         ; Jump to next method 
 
 ;====================================================== 
 ; Shift and Add 
 ;------------------------------------------------------ 
 ; This method uses the most significant bits of the 
 ; accumulator to keep track of the bit count as the 
 ; remaining data value bits are shifted out of least 
 ; significant position. 
 ; 
 ; The follow illustrates the intermediate states of the 
 ; calculation for the sample $54 value. The : shows the 
 ; division between the running count and the remaining 
 ; uncounted bits. 
 ; 
 ; +-------------------------------+ 
 ; | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 0 |  Initial value 
 ; +-------------------------------+ 
 ; | 0 | 0 : 1 | 0 | 1 | 0 | 1 | 0 |  C = 0 skip add 
 ; +-------------------------------+ 
 ; | 0 | 0 | 0 : 1 | 0 | 1 | 0 | 1 |  C = 0 skip add 
 ; +-------------------------------+ 
 ; | 0 | 0 | 0 | 0 : 1 | 0 | 1 | 0 |  C = 1 
 ; | 0 | 0 | 0 | 1 : 1 | 0 | 1 | 0 |  Add $0F+C ($10) 
 ; +-------------------------------+ 
 ; | 0 | 0 | 0 | 0 | 1 : 1 | 0 | 1 |  C = 0 skip add 
 ; +-------------------------------+ 
 ; | 0 | 0 | 0 | 0 | 0 | 1 : 1 | 0 |  C = 1 
 ; | 0 | 0 | 0 | 0 | 1 | 0 : 1 | 0 |  Add $03+1 ($04) 
 ; +-------------------------------+ 
 ; | 0 | 0 | 0 | 0 | 0 | 1 | 0 : 1 |  C = 0 skip add 
 ; +-------------------------------+ 
 ; | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 :  C = 1 
 ; +-------------------------------+ 
 ; | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 |  Add $00+C ($01) 
 ; +-------------------------------+ 
 ; 
 ; Time: 40 to 46 cycles (depending on the value) 
 ; Size: 34 bytes 
 
 BitCountShiftAdd: 
         LSR                     ; Is bit 0 set? 
         BCC .Skip0 
         ADC #$3F                ; Yes, add $40 
 .Skip0  LSR                     ; Is bit 1 set? 
         BCC .Skip1 
         ADC #$1F                ; Yes, add $20 
 .Skip1  LSR                     ; Is bit 2 set? 
         BCC .Skip2 
         ADC #$0F                ; Yes, add $10 
 .Skip2  LSR                     ; Is bit 3 set? 
         BCC .Skip3 
         ADC #$07                ; Yes, add $08 
 .Skip3  LSR                     ; Is bit 4 set? 
         BCC .Skip4 
         ADC #$03                ; Yes, add $04 
 .Skip4  LSR                     ; Is bit 5 set? 
         BCC .Skip5 
         ADC #$01                ; Yes, add $02 
 .Skip5  LSR 
         ADC #$00                ; Add bit 6 to count 
         RTS 
 
 ;------------------------------------------------------ 
 
 ShiftAndAdd: 
         LDA #$54                ; Load a test value 
         JSR BitCountShiftAdd    ; Calculate the count 
 
         NOP                     ; Result is in A 
 
         JMP DivideAndConquer    ; Jump to next method 
 
 ;====================================================== 
 ; Divide and Conquer 
 ;------------------------------------------------------ 
 ; This algorithm works by aligning and adding parts of 
 ; the value until finally the bit count is produced. 
 ; 
 ; +-------------------------------- 
 ; | 0 + 1 | 1 + 0 | 0 + 1 | 1 + 1 | 
 ; +---v-------v-------v-------v---- 
 ; | 0   1 + 0   1 | 0   1 + 1   0 | 
 ; +-------v---------------v-------- 
 ; | 0   0   1   0 + 0   0   1   1 | 
 ; +---------------v---------------- 
 ; | 0   0   0   0   0   1   0   1 | 
 ; +-------------------------------- 
 ; 
 ; This method always takes the same amount of time 
 ; regardless of the value 
 ; 
 ; Time: 50 cycles 
 ; Size: 34 bytes 
 
 BitCountParallel: 
         TAX 
         AND #$55                ; Strip out odd bits 
         STA SCRATCH 
         TXA 
         AND #$AA                ; Strip out even bits 
         LSR 
         ADC SCRATCH             ; And add together 
         TAX 
         AND #$33                ; Strip out odd pairs 
         STA SCRATCH 
         TXA 
         AND #$CC                ; Strip out even pairs 
         LSR 
         LSR 
         ADC SCRATCH             ; And add together 
         STA SCRATCH 
         LSR                     ; Shift down hi nybble 
         LSR 
         LSR 
         LSR 
         ADC SCRATCH             ; Add to lo nybble 
         AND #$0F                ; And prune to result 
         RTS 
 
 ;------------------------------------------------------ 
 
 DivideAndConquer: 
         LDA #$54                ; Load a test value 
         JSR BitCountParallel    ; Calculate the count 
 
         NOP                     ; Result is in A 
 
         BRK                     ; All done 
 
         .END 