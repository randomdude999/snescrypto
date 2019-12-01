
; same operation for encrypt and decrypt
; store nonce in !iv
; A=input length in bytes
; X=input pointer
; Y=output pointer
; enter with REP #$30, exit with SEP #$30
; push the length before entering
CTRxcrypt:
    STX !_+9
    STY !_+11
    STA !_+13
.loop:
    SEP #$30
    LDY #$0F
-   LDA !iv,y
    STA !state,y
    DEY
    BPL -
    LDA $03,s
    JSR Cipher
    
    ; increment counter
    ; not in 16bit mode because this shit is big endian
    LDA !iv+$F
    CLC : ADC #$01
    STA !iv+$F
    LDY #$0E
-   LDA !iv,y
    ADC #$00
    STA !iv,y
    DEY
    BPL -
    REP #$20
    
    ; do the xor'ing shit
    LDA #$000F
    CMP !_+13
    BCS .lastblk
    ; carry clear in this branch
    LDY #$0E
-   LDA (!_+9),y
    EOR !state,y
    STA (!_+11),y
    DEY
    DEY
    BPL -
    ; update number of bytes left
    LDA !_+13
    ; to avoid SEC, decrement the data by one
    SBC #$000F
    BEQ .return
    STA !_+13
    LDA !_+9
    CLC : ADC #$0010
    STA !_+9
    LDA !_+11
    CLC : ADC #$0010
    STA !_+11
    BRA .loop
.lastblk:
    SEP #$20
    LDY !_+13
    DEY
-   LDA (!_+9),y
    EOR !state,y
    STA (!_+11),y
    DEY
    BPL -
.return:
    RTS
