org $8000
RESET:
    ; shit
    CLC
    XCE
    REP #$38
    JSR SHA1Initialize
    
    LDX #myblk
    LDA #myblk_end-myblk
    JSR SHA1Update

    LDY #$0300
    JSR SHA1Finalize
    
    - BRA -


myblk:
db "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
.end

incsrc sha1.asm

org $fffc
dw RESET
