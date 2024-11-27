.export _registerIrq
.export _unregisterIrq
.export _setGraphicsMode
.export _setTextMode

.segment "CODE"

;Top Raster
RASTER1 = (8 * 00) + 50

;Bottom Raster
RASTER2 = (8 * 12) + 50

;------------------------------------------------------------------------------
; void registerIrq(void)
; https://www.c64-wiki.com/wiki/Raster_interrupt
_registerIrq:
        SEI                  ; Disable interrupts
        LDA #%01111111       ; Interrupt release on all bits
        STA $DC0D            ; CIA Interrupt control and status register

        LDA #$1b             ; clear most significant bit of
        STA $D011            ; VIC Control Register 1

        LDA $DC0D            ; acknowledge pending interrupts from CIA-1
        LDA $DD0D            ; acknowledge pending interrupts from CIA-2

        LDA #RASTER1         ; set rasterline where interrupt shall occur in the
        STA $D012

        LDA #<Irq1           ; set interrupt vectors, pointing to interrupt service routine below
        STA $0314
        LDA #>Irq1
        STA $0315

        LDA #1               ; enable raster interrupt signals from VIC
        STA $D01A

        CLI                  ; clear interrupt flag, allowing the CPU to respond to interrupt requests
        RTS

;------------------------------------------------------------------------------
; void unregisterIrq(void)
; 
_unregisterIrq:
        SEI                  ; Disable interrupts
        LDA #%01111111       ; Interrupt release on all bits
        STA $DC0D            ; CIA Interrupt control and status register

        LDA #$1b             ; clear most significant bit of
        STA $D011            ; VIC Control Register 1

        LDA $DC0D            ; acknowledge pending interrupts from CIA-1
        LDA $DD0D            ; acknowledge pending interrupts from CIA-2

        LDA #$31             ; set interrupt vectors, pointing to interrupt service routine below
        STA $0314
        LDA #$ea
        STA $0315

        CLI                  ; clear interrupt flag, allowing the CPU to respond to interrupt requests
        RTS

;------------------------------------------------------------------------------
; Interrupts
Irq1:
        JSR _setGraphicsMode

        LDA #0               ; set black as the
        STA $d020            ; border color

        LDA #<Irq2           ; set interrupt vectors to the second interrupt service routine at Irq2
        STA $0314
        LDA #>Irq2
        STA $0315

        LDA #RASTER2         ; set next raster line
        STA $D012

        ASL $D019            ; acknowledge the interrupt by clearing the VIC's interrupt flag
        JMP $EA81            ; jump into shorter ROM routine to only restore registers from the stack etc.

Irq2:
        JSR _setTextMode

        LDA #6               ; set blue as the
        STA $d020            ; border color

        LDA #<Irq1           ; set interrupt vectors back to the first interrupt service routine at Irq
        STA $0314
        LDA #>Irq1
        STA $0315

        LDA #RASTER1         ; set next raster line
        STA $D012

        ASL $D019            ; acknowledge the interrupt by clearing the VIC's interrupt flag
        JMP $EA31            ; jump into KERNAL's Standard interrupt service routine to handle keyboard scan, cursor display etc.

_setGraphicsMode:
        ; https://www.c64-wiki.com/wiki/Multicolor_Bitmap_Mode
        LDA #59              ; enable bitmap mode (BMM) b5=1
                             ; disable ext. color mode (ECM) b6=0
        STA $D011            ; VIC Control Register 1

        LDA #216             ; enable multi-color mode (MCM) b4=1
        STA $D016            ; VIC Control Register 2
            
        LDA #24              ; set bitmap location
        STA $D018            ; VIC Memory Control Register

        LDA #196             ; use VIC bank 3 for graphics b1=0, b0=0
        STA $DD00            ; VIC Bank
        RTS

_setTextMode:
        ; https://www.c64-wiki.com/wiki/Standard_Character_Mode
        LDA #27              ; disable ECM and BMM b6=0, b5=0
        STA $D011            ; VIC Control Register 1

        LDA #200             ; disable multi-color mode (MCM) b4=0
        STA $D016            ; VIC Control Register 2
            
        LDA #21              ; screen at 1024, with standard chars
        STA $D018            ; VIC Memory Control Register

        LDA #199             ; use VIC bank 0 for graphics b1=1, b0=1
        STA $DD00            ; VIC Bank
        RTS

