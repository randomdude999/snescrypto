; pointer to data in X
; length in A
; enter with REP #$30
SHA1Update:
    STX !_+2
    LDX !count
    STA !_+24
    ; update bit count
    STZ !_+0
    ASL
    ROL !_+0
    ASL
    ROL !_+0
    ASL
    ROL !_+0
    ; carry clear already because shifting 3 bits won't overflow
    ADC !count
    STA !count
    LDA !count+2
    ADC !_+0
    STA !count+2
    LDA !count+4
    ADC #$0000
    STA !count+4
    LDA !count+6
    ADC #$0000
    STA !count+6

    ; compute number of bytes in the current buffer
    TXA
    LSR
    LSR
    LSR
    AND #$003F

    ; need to copy data into !block
    ; continue from where we left off
    TAX
    LDY #$0000
    SEP #$20
-   LDA !_+2,y
    STA !block,x
    INX
    INY
    CPX #$0040
    BEQ +
    CPY !_+24
    BEQ ++
    BRA -
+   REP #$20
    PHY
    PHX
    JSR SHA1Transform
    PLX
    PLY
    CPY !_+24
    BNE -
++  REP #$20
    
