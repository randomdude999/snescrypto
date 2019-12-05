org $8000
RESET:
    ; shit
    CLC
    XCE
    REP #$38
    JSR SHA1Initialize
    
    LDX #myblk
    ; !block but it's not defined yet
    LDY #$0200
    LDA #$003F
    MVN $00,$00

    JSR SHA1Transform
    
    - BRA -


myblk:
db "abc"
db $80
rep 52 : db $00

rep 7 : db $00
db $18

incsrc sha1.asm

org $fffc
dw RESET
