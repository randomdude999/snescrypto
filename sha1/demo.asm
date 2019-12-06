org $8000
RESET:
    ; shit
    CLC
    XCE
    REP #$38
    JSR SHA1Initialize
    
    LDX #myblk
    LDA #myblk_sub-myblk
    JSR SHA1Update

    LDX #myblk_sub
    LDA #myblk_end-myblk_sub
    JSR SHA1Update
    
    - BRA -


myblk:
db "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
db $80
rep 7 : db $00
.sub
rep 62 : db $00
db $01,$C0
.end

incsrc sha1.asm

org $fffc
dw RESET
