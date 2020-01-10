; Y = pointer to place where to store the resulting hash
SHA256Finalize:
    PEA #32
.common:
    PHY
    ; add the 0x80 byte
    LDA !count
    LSR
    LSR
    LSR
    AND #$003F
    TAX
    SEP #$20
    LDA #$80
    STA !block,x
    REP #$20
    INX
    CPX #$0040
    BNE +
    JSR SHA256Transform
    LDX #$0000
+   ; add the bunch of nulls now
    CPX #$0038
    BEQ .addlen
    BCC .thisblk
    SEP #$20
    LDA #$00
-   STA !block,x
    INX
    CPX #$0040
    BNE -
    REP #$20

    JSR SHA256Transform
    LDX #$0000
.thisblk:
    SEP #$20
    LDA #$00
-   STA !block,x
    INX
    CPX #$0038
    BNE -
    REP #$20
.addlen:
    LDA !count
    XBA
    STA !block+62
    LDA !count+2
    XBA
    STA !block+60
    LDA !count+4
    XBA
    STA !block+58
    LDA !count+6
    XBA
    STA !block+56

    JSR SHA256Transform

    ; now just write the hash to the right place
    PLX
    PLA
    STA !_+0
    LDY #$0000
-       LDA !state+2,y
        XBA
        STA $0000,x
        LDA !state+0,y
        XBA
        STA $0002,x
        ; now add 4 to x and to y
        INX : INX : INX : INX
        INY : INY : INY : INY
        CPY !_+0
        BNE -
    RTS

; Y = pointer to where to store the resulting hash
SHA224Finalize:
    PEA #28
    JMP SHA256Finalize_common
