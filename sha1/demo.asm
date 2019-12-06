org $8000
RESET:
    ; shit
    CLC
    XCE
    REP #$38
    JSR SHA1Initialize
    
    LDX #myblk
    LDA #$0003
    JSR SHA1Update

    LDX #myblk_sub
    LDA #myblk_end-myblk_sub
    JSR SHA1Update
    
    - BRA -


myblk:
db "abc"
.sub
db $80
rep 52 : db $00

rep 7 : db $00
db $18
.end

incsrc sha1.asm

org $fffc
dw RESET
