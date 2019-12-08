; Y = pointer to place where to store the resulting hash
SHA1Finalize:
    PHY
    ; add the 0x80 byte
    LDA !count
    LSR
    LSR
    LSR
    TAX
    SEP #$20
    LDA #$80
    STA !block,x
    REP #$20
    INX
    CPX #$0040
    BNE +
    JSR SHA1Transform
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

    JSR SHA1Transform
    LDA #$0000
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

    JSR SHA1Transform

    ; now just write the hash to the right place
    PLX
    LDA !state+2
    XBA
    STA $0000,x
    LDA !state+0
    XBA
    STA $0002,x
    LDA !state+6
    XBA
    STA $0004,x
    LDA !state+4
    XBA
    STA $0006,x
    LDA !state+10
    XBA
    STA $0008,x
    LDA !state+8
    XBA
    STA $000A,x
    LDA !state+14
    XBA
    STA $000C,x
    LDA !state+12
    XBA
    STA $000E,x
    LDA !state+18
    XBA
    STA $0010,x
    LDA !state+16
    XBA
    STA $0012,x
    RTS

