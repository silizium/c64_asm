.org $0810           ; Program starts at $0810 (2064 decimal)
LDX #$17          ; Load X with 23 (message length - 1, 0-based index)
loop:             ; Start of loop
LDA message,X     ; Load byte from message + X
EOR #$42          ; Decode by XORing with $42
STA $0400,X       ; Store at $0400 + 23 - X (reverse position)
DEX               ; Decrement X
BPL loop          ; Branch to loop if X >= 0 (not negative)
RTS               ; Return when done
message:          ; Encoded message data (24 bytes)
.byte $16, $0A, $0B, $11, $62, $0A, $07, $03, $10, $16, $62, $0B, $11, $62, $10, $07, $0E, $07, $0C, $16, $0E, $07, $11, $11
