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
        !i #= !i+1
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
    ADC <z>+2
    TAY

    TXA
    CLC : ADC !_+0
    STA <z>
    TYA
    ADC !_+2
    STA <z>+2

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
    WDM #$00
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
!d = !_+16
!e = !_+20
    !i #= 0
    while !i < 5
        LDA !state+0+!i*4
        STA !_+4+!i*4
        LDA !state+2+!i*4
        STA !_+6+!i*4
        !i #= !i+1
    endif
    ; TODO: check how big the full transform function gets. if ridiculous, use a loop instead, shifting the variables over by 1 each iteration (still unrolled 5x, but that isn't as bad as 80x)
    %R(!a,!b,!c,!d,!e,0,0)
    %R(!e,!a,!b,!c,!d,1,0)
    %R(!d,!e,!a,!b,!c,2,0)
    %R(!c,!d,!e,!a,!b,3,0)
    %R(!b,!c,!d,!e,!a,4,0)
    %R(!a,!b,!c,!d,!e,5,0)
    %R(!e,!a,!b,!c,!d,6,0)
    %R(!d,!e,!a,!b,!c,7,0)
    %R(!c,!d,!e,!a,!b,8,0)
    %R(!b,!c,!d,!e,!a,9,0)
    %R(!a,!b,!c,!d,!e,10,0)
    %R(!e,!a,!b,!c,!d,11,0)
    %R(!d,!e,!a,!b,!c,12,0)
    %R(!c,!d,!e,!a,!b,13,0)
    %R(!b,!c,!d,!e,!a,14,0)
    %R(!a,!b,!c,!d,!e,15,0)
    %R(!e,!a,!b,!c,!d,16,0)
    %R(!d,!e,!a,!b,!c,17,0)
    %R(!c,!d,!e,!a,!b,18,0)
    %R(!b,!c,!d,!e,!a,19,0)

    %R(!a,!b,!c,!d,!e,20,2)
    %R(!e,!a,!b,!c,!d,21,2)
    %R(!d,!e,!a,!b,!c,22,2)
    %R(!c,!d,!e,!a,!b,23,2)
    %R(!b,!c,!d,!e,!a,24,2)
    %R(!a,!b,!c,!d,!e,25,2)
    %R(!e,!a,!b,!c,!d,26,2)
    %R(!d,!e,!a,!b,!c,27,2)
    %R(!c,!d,!e,!a,!b,28,2)
    %R(!b,!c,!d,!e,!a,29,2)
    %R(!a,!b,!c,!d,!e,30,2)
    %R(!e,!a,!b,!c,!d,31,2)
    %R(!d,!e,!a,!b,!c,32,2)
    %R(!c,!d,!e,!a,!b,33,2)
    %R(!b,!c,!d,!e,!a,34,2)
    %R(!a,!b,!c,!d,!e,35,2)
    %R(!e,!a,!b,!c,!d,36,2)
    %R(!d,!e,!a,!b,!c,37,2)
    %R(!c,!d,!e,!a,!b,38,2)
    %R(!b,!c,!d,!e,!a,39,2)

    %R(!a,!b,!c,!d,!e,40,3)
    %R(!e,!a,!b,!c,!d,41,3)
    %R(!d,!e,!a,!b,!c,42,3)
    %R(!c,!d,!e,!a,!b,43,3)
    %R(!b,!c,!d,!e,!a,44,3)
    %R(!a,!b,!c,!d,!e,45,3)
    %R(!e,!a,!b,!c,!d,46,3)
    %R(!d,!e,!a,!b,!c,47,3)
    %R(!c,!d,!e,!a,!b,48,3)
    %R(!b,!c,!d,!e,!a,49,3)
    %R(!a,!b,!c,!d,!e,50,3)
    %R(!e,!a,!b,!c,!d,51,3)
    %R(!d,!e,!a,!b,!c,52,3)
    %R(!c,!d,!e,!a,!b,53,3)
    %R(!b,!c,!d,!e,!a,54,3)
    %R(!a,!b,!c,!d,!e,55,3)
    %R(!e,!a,!b,!c,!d,56,3)
    %R(!d,!e,!a,!b,!c,57,3)
    %R(!c,!d,!e,!a,!b,58,3)
    %R(!b,!c,!d,!e,!a,59,3)

    %R(!a,!b,!c,!d,!e,60,4)
    %R(!e,!a,!b,!c,!d,61,4)
    %R(!d,!e,!a,!b,!c,62,4)
    %R(!c,!d,!e,!a,!b,63,4)
    %R(!b,!c,!d,!e,!a,64,4)
    %R(!a,!b,!c,!d,!e,65,4)
    %R(!e,!a,!b,!c,!d,66,4)
    %R(!d,!e,!a,!b,!c,67,4)
    %R(!c,!d,!e,!a,!b,68,4)
    %R(!b,!c,!d,!e,!a,69,4)
    %R(!a,!b,!c,!d,!e,70,4)
    %R(!e,!a,!b,!c,!d,71,4)
    %R(!d,!e,!a,!b,!c,72,4)
    %R(!c,!d,!e,!a,!b,73,4)
    %R(!b,!c,!d,!e,!a,74,4)
    %R(!a,!b,!c,!d,!e,75,4)
    %R(!e,!a,!b,!c,!d,76,4)
    %R(!d,!e,!a,!b,!c,77,4)
    %R(!c,!d,!e,!a,!b,78,4)
    %R(!b,!c,!d,!e,!a,79,4)

    !i #= 0
    while !i < 5
        LDA !_+4+!i*4
        CLC
        ADC !state+0+!i*4
        STA !state+0+!i*4
        LDA !_+6+!i*4
        ADC !state+2+!i*4
        STA !state+2+!i*4
        ;STZ !_+4+!i*4
        ;STZ !_+6+!i*4
        !i #= !i+1
    endif

    RTS
