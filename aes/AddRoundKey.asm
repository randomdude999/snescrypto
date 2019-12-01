
; round number is in A
; wrecks A,X,Y
AddRoundKey:
    ASL
    ASL
    ASL
    ASL
    ; carry clear because round number can't overflow
    ADC #$0E
    TAY
    LDX #$0E
    REP #$20
-   LDA !keybuffer,y
    EOR !state,x
    STA !state,x
    DEY
    DEY
    DEX
    DEX
    BPL -
    SEP #$20
    RTS
