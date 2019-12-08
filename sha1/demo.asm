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
db "abc"
.end
;db $80
;rep 7 : db $00
;.sub
;rep 62 : db $00
;db $01,$C0
;.end

incsrc sha1.asm

org $fffc
dw RESET
