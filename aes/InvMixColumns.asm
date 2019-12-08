
; oh god this is gonna be horrible

; uses !xtime from MixColumns.asm

; TODO: check how big/fast this thing would be when using a LUT for !xtime
; (i'm honestly thinking it may be shorter)

macro MulThing9(off)
    LDA !_+<off>
    !xtime
    !xtime
    !xtime
    EOR !_+<off>
endmacro
macro MulThingB(off)
    LDA !_+<off>
    !xtime
    STA !_+4
    !xtime
    !xtime
    EOR !_+4
    EOR !_+<off>
endmacro
macro MulThingD(off)
    LDA !_+<off>
    !xtime
    !xtime
    STA !_+4
    !xtime
    EOR !_+4
    EOR !_+<off>
endmacro
macro MulThingE(off)
    LDA !_+<off>
    !xtime
    STA !_+4
    !xtime
    STA !_+5
    !xtime
    EOR !_+5
    EOR !_+4
endmacro

; wrecks A,X, !_+{0..6}
InvMixColumns:
    LDX #$0C
.loop

    REP #$20
    LDA !state+0,x
    STA !_+0
    LDA !state+2,x
    STA !_+2
    SEP #$20

    %MulThingE(0)
    STA !_+6
    %MulThingB(1)
    EOR !_+6
    STA !_+6
    %MulThingD(2)
    EOR !_+6
    STA !_+6
    %MulThing9(3)
    EOR !_+6
    STA !state+0,x

    %MulThing9(0)
    STA !_+6
    %MulThingE(1)
    EOR !_+6
    STA !_+6
    %MulThingB(2)
    EOR !_+6
    STA !_+6
    %MulThingD(3)
    EOR !_+6
    STA !state+1,x

    %MulThingD(0)
    STA !_+6
    %MulThing9(1)
    EOR !_+6
    STA !_+6
    %MulThingE(2)
    EOR !_+6
    STA !_+6
    %MulThingB(3)
    EOR !_+6
    STA !state+2,x

    %MulThingB(0)
    STA !_+6
    %MulThingD(1)
    EOR !_+6
    STA !_+6
    %MulThing9(2)
    EOR !_+6
    STA !_+6
    %MulThingE(3)
    EOR !_+6
    STA !state+3,x

    DEX
    DEX
    DEX
    DEX
    BMI +
    JMP .loop
+   RTS
