
; multi-block variant
; enter with REP #$30 (only for IO), exit with SEP #$30
; A=number of bytes (padded! use the pkcs7 wrapper if you want it) (this is rounded down if not even so you can handle the last block specially yourself)
; X=source pointer
; Y=dest pointer
; push the key width before calling
; source data is untouched
CBCEncrypt:
; wrecks A,X,Y,!_+{0..14}
    LSR
    LSR
    LSR
    LSR
    STA !_+9
    STX !_+11
    STY !_+13
    SEP #$30
    ; still the result of the ASL in Z
    BEQ .return
.loop:
    LDY #$0F
-   LDA (!_+11),y
    STA !state,y
    DEY
    BPL -

    ;LDA !_+10
    ;SEC : SBC #$10
    ;STA !_+10
    
    LDA $03,s ; change to 4 if you change RTS
    TAY
    JSR CBCEncryptSingle

    LDY #$0F
-   LDA !state,y
    STA (!_+13),y
    DEY
    BPL -

    REP #$21
    LDA #$0010
    ADC !_+11
    STA !_+11
    LDA #$0010
    CLC : ADC !_+13
    STA !_+13

    DEC !_+9
    SEP #$20

    BNE .loop

    ; just in case
    LDA #$00
.return:
    RTS



; same entry params as CBCEncrypt, but pads the length with PKCS7 if it isn't a multiple of blocksize (except it doesn't actually mutate the input)
CBCEncryptPKCS7:
    SEP #$20
    STA !_+15 ; yo i think we fuckin overflowed our 16 bytes scratch
    ; we only need to store the low byte though...
    LDA $03,s
    PHA
    LDA !_+15
    REP #$20
    JSR CBCEncrypt
    ; PLA
    SEP #$21 ; also set carry for one SBC later
    LDA !_+15
    AND #$0F ; last block len
    BEQ .fullblkpad ; if even multiple of blocksize, we need an entire block of padding
    STA !_+0
    TAY
    DEY
    ; !_+1 number of actual bytes in last blk - 1
    ; also index of last written byte in the block
    STY !_+1
    ; copy over the block itself
-   LDA (!_+11),y
    STA !state,y
    DEY
    BPL -
    ; compute length of padding now
    LDA #$10
    SBC !_+0 ; carry is set from the SEP way back
    LDY #$0F
-   STA !state,y
    DEY
    CPY !_+1
    BNE -
.fullblkret:
    ; alright, block finally padded
    PLY
    JSR CBCEncryptSingle
    
    LDY #$0F
-   LDA !state,y
    STA (!_+13),y
    DEY
    BPL -

    LDA #$00
.return:
    RTS

.fullblkpad:
    LDA #$10
    LDY #$0F
-   STA !state,y
    DEY
    BPL -
    BRA .fullblkret

; single-block variant
; stuff to encrypt in !state
; IV in !iv if first block
; output in !state
; key width in Y
; SEP #$30 on entry
CBCEncryptSingle:
    LDX #$0F
-   LDA !state,x
    EOR !iv,x
    STA !state,x
    DEX
    BPL -
    TYA
    JSR Cipher
    LDX #$0F
-   LDA !state,x
    STA !iv,x
    DEX
    BPL -
    RTS
