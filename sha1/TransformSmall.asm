math pri on

; WIP

; names for the various used scratch variables
!a = !_+4
!b = !_+8
!c = !_+12
!d = !_+16
!e = !_+20
!roundcounta = !_+24 ; 2 bytes (only low values are used, but rep/sep is slow)
!roundcountb = !_+32 ; used to count rounds mod 20, for cycling the round-specific ops
!f = !_+26 ; 2 bytes (temporary for doing the cyclic shifting of variables at one point)
!blkptr = !_+28 ; 4 bytes, temporary pointer



UpdateRoundConsts:
    LDA !roundcounta
    BNE +
    JMP .first
    !i #= 0
+   while !i < 16
        LDA !block+((!i+0)&15)*4
        EOR !block+((!i+2)&15)*4
        EOR !block+((!i+8)&15)*4
        EOR !block+((!i+13)&15)*4
        ASL
        STA !block+((!i+0)&15)*4
        LDA !block+((!i+0)&15)*4+2
        EOR !block+((!i+2)&15)*4+2
        EOR !block+((!i+8)&15)*4+2
        EOR !block+((!i+13)&15)*4+2
        ROL
        STA !block+((!i+0)&15)*4+2
        LDA #$0000
        ROL
        TSB !block+((!i+0)&15)*4
        !i #= !i+1
    endif
    RTS
.first:
    !i #= 0
    while !i < 16
        LDA !block+!i*4
        XBA
        LDX !block+!i*4+2
        STA !block+!i*4+2
        TXA
        XBA
        STA !block+!i*4
        !i #= !i+1
    endif
    ; we need to clear X somewhere for the first iter, might as well be here
    LDX #$0000
    RTS

RoundCommon:
    LDA !a
    STA !_+0
    LDA !a+2
    STA !_+2
    LDA #$0000
    !i #= 0
    while !i < 5
        ASL !_+0
        ROL !_+2
        ROL
        !i #= !i+1
    endif
    TSB !_+0
    
    LDA #$0000
    LSR !b+2
    ROR !b+0
    ROR
    LSR !b+2
    ROR !b+0
    ROR
    TSB !b+2


    TXA
    CLC : ADC !e
    TAX
    TYA
    ADC !e+2
    TAY

    TXA
    CLC : ADC !_+0
    STA !_ ;TAX
    TYA
    ADC !_+2
    TAY

    RTS

R0:
    LDA !c
    EOR !d
    AND !b
    EOR !d
    CLC : ADC !blkptr
    TAX
    LDA !c+2
    EOR !d+2
    AND !b+2
    EOR !d+2
    ADC !blkptr+2
    TAY
    RTS

R1:
    LDA !b
    EOR !c
    EOR !d
    CLC : ADC !blkptr
    TAX
    LDA !b+2
    EOR !c+2
    EOR !d+2
    ADC !blkptr+2
    TAY
    RTS

R2:
    LDA !b
    ORA !c
    AND !d
    STA !_+0
    LDA !b
    AND !c
    ORA !_+0
    CLC : ADC !blkptr
    TAX

    LDA !b+2
    ORA !c+2
    AND !d+2
    STA !_+0
    LDA !b+2
    AND !c+2
    ORA !_+0
    ADC !blkptr+2
    TAY
    RTS

R3:
    LDA !b
    EOR !c
    EOR !d
    CLC : ADC !blkptr
    TAX
    LDA !b+2
    EOR !c+2
    EOR !d+2
    ADC !blkptr+2
    TAY
    RTS

RoundSpecificFuncTbl:
    dw R0
    dw R1
    dw R2
    dw R3

RoundSpecificConstsLow:
    dw $7999
    dw $EBA1
    dw $BCDC
    dw $C1D6

RoundSpecificConstsHigh:
    dw $5A82
    dw $6ED9
    dw $8F1B
    dw $CA62

ShiftVars:
    !off = 0
    while !off < 4 ; loop twice
        LDY !a+!off
        LDA !e+!off
        STA !a+!off
        LDA !d+!off
        STA !e+!off
        LDA !c+!off
        STA !d+!off
        LDA !b+!off
        STA !c+!off
        STY !b+!off
        !off #= !off+2
    endif
    RTS

; asdf
; enter with REP #$30
; !block - the data to hash (64 bytes) (note: will be overwritten)
; !state - the current state (5*4 bytes) (obviously will be overwritten)
; needs 34 bytes of scratch in !_
SHA1Transform:
    !i #= 0
    while !i < 5
        LDA !state+0+!i*4
        STA !_+4+!i*4
        LDA !state+2+!i*4
        STA !_+6+!i*4
        !i #= !i+1
    endif

    STZ !roundcounta
    STZ !roundcountb ; mod 20, used for other check
-   LDA !roundcounta
    AND #$000F
    BNE +
    JSR UpdateRoundConsts
    LDA #$0000
+   ASL
    ASL
    TAY
    LDA !block,y
    STA !blkptr
    LDA !block+2,y
    STA !blkptr+2
 
    STX !f ; back up the index, it's overwritten by temps

    ; round-specific function
    JSR (RoundSpecificFuncTbl,x)
    JSR RoundCommon
    ; now the round-specific end
    LDX !f
    LDA !_ ; we write to !_ instead of moving to X as the last part of RoundCommon
    CLC : ADC RoundSpecificConstsLow,x
    STA !e
    TYA
    ADC RoundSpecificConstsHigh,x
    STA !e+2
    JSR ShiftVars
    ; next loop iteration
    ; roundcounta is the real round counter, X is round//20*2, used as an index to the round-specific things
    INC !roundcounta
    LDA !roundcountb
    INC
    STA !roundcountb
    CMP.w #20
    BNE -
    STZ !roundcountb
    INX
    INX
    CPX.w #8
    BNE -

    STZ !_+0
    STZ !_+2
    ; the only place that *should* call this is SHA1Update, which backs up X and Y for its own use
    ;LDX #$0000
    ;LDY #$0000
    !i #= 0
    while !i < 5
        LDA !_+4+!i*4
        CLC
        ADC !state+0+!i*4
        STA !state+0+!i*4
        LDA !_+6+!i*4
        ADC !state+2+!i*4
        STA !state+2+!i*4
        STZ !_+4+!i*4
        STZ !_+6+!i*4
        !i #= !i+1
    endif

    RTS
