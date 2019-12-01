org $8000
RESET:
    CLC : XCE
    REP #$18
    SEP #$20
    LDX #$1FFF
    TXS
    LDX #Key
    LDA #$04
    PHA
    JSR KeyExpansion
    REP #$30
    LDA #$000F
    LDX #IV
    LDY #$0200
    MVN $00,$00
    LDX #Plaintext
    LDY #$0300
    LDA #Plaintext_end-Plaintext
    JSR CBCEncryptPKCS7
-   BRA -

Key:
db $2B,$7E,$15,$16,$28,$AE,$D2,$A6,$AB,$F7,$15,$88,$09,$CF,$4F,$3C

IV:
db $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF

Plaintext:
db $6B,$C1,$BE,$E2,$2E,$40,$9F,$96,$E9,$3D,$7E,$11,$73,$93,$17,$2A
db $AE,$2D,$8A,$57,$1E,$03,$AC,$9C,$9E,$B7,$6F,$AC,$45,$AF,$8E,$51
db $30,$C8,$1C,$46,$A3,$5C,$E4,$11,$E5,$FB,$C1,$19,$1A,$0A,$52,$EF
db $F6,$9F,$24,$45,$DF,$4F,$9B,$17
.end:

incsrc AES.asm

org $FFFC
dw RESET
