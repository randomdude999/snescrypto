extra_blk: db $80

; Y = pointer to place where to store the resulting hash
SHA1Finalize:
    PHY
    ; todo: should probably not call sha1update here, seems a bit wasteful
    LDX #extra_blk
    LDA #$0001
    JSR SHA1Update
    ; add the bunch of nulls now
    LDA !count
    LSR
    LSR
    LSR
    AND #$003F
    CMP #$0038
    BEQ .addlen
    BCC .thisblk
    TAX
    SEP #$20
    LDA #$00
-   STA !block,x
    INX
    CPX #$0040
    BNE -
    REP #$20
    ; update bit count
    LDA !count
    AND #$01F8
    STA !_+0
    LDA #$0200
    SEC : SBC !_+0
    CLC : ADC !count
    STA !count
    LDA !count+2
    ADC #$0000
    STA !count+2
    LDA !count+4
    ADC #$0000
    STA !count+4
    LDA !count+6
    ADC #$0000
    STA !count+6

    JSR SHA1Transform
    LDA #$0000
.thisblk:
    TAX
    SEP #$20
    LDA #$00
-   STA !block,x
    INX
    CPX #$0038
    BNE -
    REP #$20
    LDA !count
    ; need to pad to xxxx_xxx1_1100_0000
    ; currently have xxxx_xxxy_yyyy_yyyy
    ; and 2nd is guaranteed smaller
    AND #$FE00
    ORA #$01C0
    STA !count
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

    ; now should just write the hash to the right place
    ; TODO
    RTS

