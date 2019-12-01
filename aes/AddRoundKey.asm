
; round number is in A
; wrecks A,X,Y
AddRoundKey:
    ASL
    ASL
    ASL
    ASL
    ; carry clear because round number can't overflow
    ; TODO use 16bit mode for EXTRA SPEED
    ADC #$0F
    TAY
    LDX #$0F
-   LDA !keybuffer,y
    EOR !state,x
    STA !state,x
    DEY
    DEX
    BPL -
    RTS
