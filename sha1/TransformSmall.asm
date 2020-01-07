math pri on

; WIP

; names for the various used scratch variables
!a = !_+4
!b = !_+8
!c = !_+12
!d = !_+16
!e = !_+20
!roundcount = !_+24 ; 2 bytes (only low values are used, but rep/sep is slow)
!f = !_+26 ; 2 bytes (temporary for doing the cyclic shifting of variables at one point)

macro ExpandStuff(i)
    LDA !roundcount
    AND #$000F
    ASL
    ASL
    ADC.w #!block
    STA !roundcount+2
    if <i> < 16
        ; do the thing called blk0 in the c impl
        ; swap bytes of i'th u32 in blk
        LDA !block+<i>*4
        XBA
        LDX !block+<i>*4+2
        STA !block+<i>*4+2
        TXA
        XBA
        STA !block+<i>*4
    else
        LDA !block+((<i>+0)&15)*4
        EOR !block+((<i>+2)&15)*4
        EOR !block+((<i>+8)&15)*4
        EOR !block+((<i>+13)&15)*4
        ASL
        STA !block+((<i>+0)&15)*4
        LDA !block+((<i>+0)&15)*4+2
        EOR !block+((<i>+2)&15)*4+2
        EOR !block+((<i>+8)&15)*4+2
        EOR !block+((<i>+13)&15)*4+2
        ROL
        STA !block+((<i>+0)&15)*4+2
        LDA #$0000
        ROL
        TSB !block+((<i>+0)&15)*4
    endif
endmacro

; macro RoundCommon(v,w,z,cl,ch)
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
    TAX
    TYA
    ADC !_+2
    TAY

    RTS

macro RoundCommonEnd(cl,ch)
    TXA
    CLC : ADC #<cl>
    STA !e
    TYA
    ADC #<ch>
    STA !e+2
endmacro

; note: this is also R1, since the difference in the blk used is handled in %expandstuff already
macro R0(i)
    LDA !c
    EOR !d
    AND !b
    EOR !d
    CLC : ADC !block+(<i>&15)*4
    TAX
    LDA !c+2
    EOR !d+2
    AND !b+2
    EOR !d+2
    ADC !block+(<i>&15)*4+2
    TAY
    JSR RoundCommon
    %RoundCommonEnd($7999,$5A82)
endmacro

macro R2(i)
    LDA !b
    EOR !c
    EOR !d
    CLC : ADC !block+(<i>&15)*4
    TAX
    LDA !b+2
    EOR !c+2
    EOR !d+2
    ADC !block+(<i>&15)*4+2
    TAY
    JSR RoundCommon
    %RoundCommonEnd($EBA1,$6ED9)
endmacro

macro R3(i)
    LDA !b
    ORA !c
    AND !d
    STA !_+0
    LDA !b
    AND !c
    ORA !_+0
    CLC : ADC !block+(<i>&15)*4
    TAX

    LDA !b+2
    ORA !c+2
    AND !d+2
    STA !_+0
    LDA !b+2
    AND !c+2
    ORA !_+0
    ADC !block+(<i>&15)*4+2
    TAY

    JSR RoundCommon
    %RoundCommonEnd($BCDC,$8F1B)
endmacro

macro R4(i)
    LDA !b
    EOR !c
    EOR !d
    CLC : ADC !block+(<i>&15)*4
    TAX
    LDA !b+2
    EOR !c+2
    EOR !d+2
    ADC !block+(<i>&15)*4+2
    TAY
    JSR RoundCommon
    %RoundCommonEnd($C1D6,$CA62)
endmacro


ShiftVars:
    !off = 0
    while !off < 4 ; loop twice
        LDX !a+!off
        LDA !e+!off
        STA !a+!off
        LDA !d+!off
        STA !e+!off
        LDA !c+!off
        STA !d+!off
        LDA !b+!off
        STA !c+!off
        STX !b+!off
        !off #= !off+2
    endif
    RTS

; asdf
; enter with REP #$30
; !block - the data to hash (64 bytes) (note: will be overwritten)
; !state - the current state (5*4 bytes) (obviously will be overwritten)
; needs 6 32-bit scratch variables, so 24 bytes of scratch total (in !_)
SHA1Transform:
    !i #= 0
    while !i < 5
        LDA !state+0+!i*4
        STA !_+4+!i*4
        LDA !state+2+!i*4
        STA !_+6+!i*4
        !i #= !i+1
    endif
    STZ !roundcount
-   %R0(0)
    ; a->tmp; e->a; d->e; c->d; b->c; tmp->b
    JSR ShiftVars
    ; next loop iteration
    LDA !roundcount
    INC
    STA !roundcount
    CMP.w #20
    BNE -

-   %R2(20)
    LDA !roundcount
    INC
    STA !roundcount
    CMP.w #40
    BNE -

-   %R3(40)
    LDA !roundcount
    INC
    STA !roundcount
    CMP.w #60
    BNE -

-   %R4(60)
    LDA !roundcount
    INC
    STA !roundcount
    CMP.w #80
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
