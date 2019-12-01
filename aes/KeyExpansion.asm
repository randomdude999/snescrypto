
RoundConst:
db $01, $02, $04, $08, $10, $20, $40, $80, $1b, $36

; pointer to key in X (16-bit, enter with REP #$10)
; key length in A (valid values: 4, 6, 8)
; wrecks A,X,Y,!_+{0..7}, exits with SEP #$30
KeyExpansion:
    ; note to self: round count is just keylen+6

    ; scratch usage:
    ; +0: backup of key length
    ; +1: counter for modulus of i
    ; +2..+3: pointer to key (free after first loop)
    ; +4..+7: temps for working on column/row operations
    ; +2: quotinent for i/keylen, minus 1 (used as index to round constant table)
    ; +3: total iter count for main loop
    STX !_+2
    SEP #$10
    STA !_+0
    ASL
    ASL
    DEC
    TAY
    ; MVN? but one source address has unknown bank
-   LDA (!_+2),y
    STA !keybuffer,y
    DEY
    BPL -
    LDY !_+0
    TYA
    CLC : ADC #$07
    ASL
    ASL
    STA !_+3
    STZ !_+1
    STZ !_+2
.loop
        TYA
        DEC
        ASL
        ASL
        TAX
        REP #$20
        LDA !keybuffer+0,x
        STA !_+4
        LDA !keybuffer+2,x
        STA !_+6
        SEP #$20
        
        ; do all the ops here
        LDA !_+1
        BNE +
            ; RotWord
            LDX !_+4
            LDA !_+7
            STX !_+7
            LDX !_+6
            STA !_+6
            LDA !_+5
            STX !_+5
            STA !_+4
            ; SubWord
            LDX !_+4
            LDA SBox,x
            STA !_+4
            LDX !_+5
            LDA SBox,x
            STA !_+5
            LDX !_+6
            LDA SBox,x
            STA !_+6
            LDX !_+7
            LDA SBox,x
            STA !_+7
            ; add round constant
            LDA !_+4
            LDX !_+2
            EOR RoundConst,x
            STA !_+4
            BRA ++
    +   ; LDA !_+1
        CMP #$04
        BNE ++
        LDA !_+0
        CMP #$08
        BNE ++
            ; SubWord
            LDX !_+4
            LDA SBox,x
            STA !_+4
            LDX !_+5
            LDA SBox,x
            STA !_+5
            LDX !_+6
            LDA SBox,x
            STA !_+6
            LDX !_+7
            LDA SBox,x
            STA !_+7
++
        ; do the main xor-ing with old round keys

        PHY ; actually as fast as sty $dp? nice
        TYA
        ASL
        ASL
        TAX
        TYA
        SEC : SBC !_+0
        ASL
        ASL
        TAY
        
        REP #$20
        LDA !keybuffer+0,y
        EOR !_+4
        STA !keybuffer+0,x
        LDA !keybuffer+2,y
        EOR !_+6
        STA !keybuffer+2,x
        SEP #$20
        
        PLY
        ; increment the modulus
        INC !_+1
        LDA !_+1
        CMP !_+0
        BNE +
        STZ !_+1
        INC !_+2
        +
    INY
    CPY !_+3
    BEQ +
    JMP .loop
+   STZ $04
    STZ $05
    STZ $06
    STZ $07
    RTS
