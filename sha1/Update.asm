; pointer to data in X
; length in A
; enter with REP #$30
SHA1Update:
    STX !_+36
    LDX !count
    STA !_+34

    ; trying to use 0 bytes will break shit, so let's just special case it
    CMP #$0000
    BNE +
    RTS
+

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
--  SEP #$20
-   LDA (!_+36),y
    STA !block,x
    INX
    INY
    CPX #$0040
    BEQ +
    CPY !_+34
    BEQ ++
    BRA -
+   REP #$20
    PHY
    JSR SHA1Transform
    LDX #$0000
    PLY
    CPY !_+34
    BNE --
++  REP #$20
    ; we done?
    RTS
