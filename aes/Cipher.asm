
; encrypt state with the initialized roundkeys in !keybuffer
; wrecks A,X,Y,!_+{0..8} or so
; key length in A
Cipher:
    CLC : ADC #$06
    STA !_+8
    LDA #$00
    JSR AddRoundKey
    LDY #$01
.loop
        JSR SubBytes
        JSR ShiftRows
        PHY
        JSR MixColumns
        ;PLY
        ;TYA
        ;PHY
        LDA $01,s
        JSR AddRoundKey
        PLY
    INY
    CPY !_+8
    BNE .loop

    JSR SubBytes
    JSR ShiftRows
    TYA
    JSR AddRoundKey
    LDA #$00
    RTS

; wrecks A,X,Y, !_+{0..7}
; key length in A
InvCipher:
    CLC : ADC #$06
    PHA
    JSR AddRoundKey
    PLA
    DEC
    TAY
.loop
        JSR InvShiftRows
        JSR InvSubBytes
        PHY
        TYA
        JSR AddRoundKey
        JSR InvMixColumns
        PLY
    DEY
    BNE .loop
    JSR InvShiftRows
    JSR InvSubBytes
    TYA
    JSR AddRoundKey
    LDA #$00
    RTS
