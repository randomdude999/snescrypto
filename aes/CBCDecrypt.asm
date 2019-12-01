; multi-block variant
; enter with REP #$30 (for io), exit with SEP #$30
; A=number of bytes in ciphertext (if not multiple of 16, will be rounded down)
; X=source pointer (ciphertext)
; Y=dest pointer (plaintext)
; push key width before calling
; source data untouched
; if data is padded with PKCS7, use the GetUnpaddedLen function to get the real length of the message and whether the padding is valid or not
CBCDecrypt:
    LSR
    LSR
    LSR
    LSR
    STA !_+8
    STX !_+10
    STY !_+12
    SEP #$30
    BEQ .return
.loop:
    ; copy over block of ciphertext into state
    LDY #$0F
-   LDA (!_+10),y
    STA !state,y
    DEY
    BPL -
    ; decrypt the block
    LDA $03,s ; change if changing the RTS
    JSR InvCipher
    ; xor with IV and store to output
    LDY #$0F
-   LDA !state,y
    EOR !iv,y
    STA (!_+12),y
    DEY
    BPL -
    ; copy the new IV (old ciphertext) over
    LDY #$0F
-   LDA (!_+10),y
    STA !iv,y
    DEY
    BPL -
    ; increment the output pointers, decrement to-be-done block count
    REP #$21 ; also CLC
    LDA !_+10
    ADC #$0010
    STA !_+10
    LDA !_+12
    CLC : ADC #$0010
    STA !_+12
    DEC !_+8
    SEP #$30
    BNE .loop
.return:
    RTS

; check whether a message has valid PKCS7 padding (note: blocksize hardcoded to 16 bytes)
; A - length of input (if it isn't a multiple of 16 then why are you even calling this)
; Y - pointer to data
; output: carry clear if padding valid, A=real length of data, carry clear if invalid, A=original length
; enter/exit with REP #$30
; uses !_+{0..1}
CheckPKCS7Padding:
    STY !_+0
    STA !_+2
    DEC
    CLC : ADC !_+0
    STA !_+0
    SEP #$20
    LDA (!_+0)
    ; A = last byte of data
    CMP #$11
    BCC +
    ; carry is set from the CMP already
    REP #$20
    LDA !_+2
    RTS
+   STA !_+4
    TAX
    LDA (!_+0)
    CMP !_+4
    ;BNE 

