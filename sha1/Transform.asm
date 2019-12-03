; probably better off sticking to 16bit mode all the time and doing the math stuff in 2 steps

; god i'm afraid that this macro hell will expand to a literal bank full of code

; based on https://gist.github.com/jrabbit/1042021, i use variable names from there in comments and stuff

; asar is kinda dumb sometimes
math pri on

macro ExpandStuff(i)
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
        ; aaaa
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

macro RoundCommon(v,w,z,cl,ch)
    LDA <v>
    STA !_+0
    LDA <v>+2
    STA !_+2
    LDA #$0000
    !i #= 0
    while !i < 5
        ASL !_+0
        ROL !_+2
        ROL
    endif
    TSB !_+0
    
    TXA
    CLC : ADC #<cl>
    TAX
    TYA
    ADC #<ch>
    TAY

    TXA
    CLC : ADC <z>
    TAX
    TYA
    ADC <z>
    TAY

    TXA
    CLC : ADC !_+0
    STA <z>
    TAY
    ADC !_+2
    STA <z>

    LDA #$0000
    LSR <w>+2
    ROR <w>+0
    ROR
    LSR <w>+2
    ROR <w>+0
    ROR
    TSB <w>+2
endmacro

; note: this is also R1, since the difference in the blk used is handled in %expandstuff already
macro R0(v,w,x,y,z,i)
    ; v-z are $xx (hopefully...)
    LDA <x>
    EOR <y>
    AND <w>
    EOR <y>
    CLC : ADC !block+(<i>&15)*4
    TAX ; STA !_+0
    LDA <x>+2
    EOR <y>+2
    AND <w>+2
    EOR <y>+2
    ADC !block+(<i>&15)*4+2
    TAY ; STA !_+2
    %RoundCommon(<v>,<w>,<z>,$7999,$5A82)
endmacro

macro R2(v,w,x,y,z,i)
    LDA <w>
    EOR <x>
    EOR <y>
    CLC : ADC !block+(<i>&15)*4
    TAX
    LDA <w>+2
    EOR <x>+2
    EOR <y>+2
    ADC !block+(<i>&15)*4+2
    TAY
    %RoundCommon(<v>,<w>,<z>,$EBA1,$6ED9)
endmacro

macro R3(v,w,x,y,z,i)
    LDA <w>
    ORA <x>
    AND <y>
    STA !_+0
    LDA <w>
    AND <x>
    ORA !_+0
    CLC : ADC !block+(<i>&15)*4
    TAX

    LDA <w>+2
    ORA <x>+2
    AND <y>+2
    STA !_+0
    LDA <w>+2
    AND <x>+2
    EOR !_+0
    ADC !block+(<i>&15)*4+2
    TAY

    %RoundCommon(<v>,<w>,<z>,$BCDC,$8F1B)
endmacro

macro R4(v,w,x,y,z,i)
    LDA <w>
    EOR <x>
    EOR <y>
    CLC : ADC !block+(<i>&15)*4
    TAX
    LDA <w>+2
    EOR <x>+2
    EOR <y>+2
    ADC !block+(<i>&15)*4+2
    TAY
    %RoundCommon(<v>,<w>,<z>,$C1D6,$CA62)
endmacro

macro R(v,w,x,y,z,i,n)
    %ExpandStuff(<i>)
    %R<n>(<v>,<w>,<x>,<y>,<z>,<i>)
endmacro

; asdf
; enter with REP #$30
; !block - the data to hash (64 bytes) (note: will be overwritten)
; !state - the current state (5*4 bytes) (obviously will be overwritten)
; needs 6 32-bit scratch variables, so 24 bytes of scratch total (in !_)
SHA1Transform:
!a = !_+4
!b = !_+8
!c = !_+12
!d = !_+14
!e = !_+16
    ; wip
    RTS
