; probably better off sticking to 16bit mode all the time and doing the math stuff in 2 steps
; ugh, sha1 uses addition, so i'll need to actually do shit

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

macro R0(v,w,x,y,z,i)
    ; v-z are $xx (hopefully...)
    ; i is a compile-time-known int
    %ExpandStuff(i)
    LDA <x>
    EOR <y>
    AND <w>
    EOR <y>
    STA !_+0
    LDA <x>+2
    EOR <y>+2
    AND <w>+2
    EOR <y>+2
    STA !_+2
    ; wip
endmacro

