
; !xtime = "ASL : BCC $02 : EOR #$1B"
; TODO: this one is pretty much the slowest part of the whole algorithm
; (at least when doing InvCipher)
; possibly add option to use a 256-byte lookup table instead of this thing?
; !xtime = "ASL : BCC + : EOR #$1B : BRA ++ : + WDM #$42 : WDM #$42 : ++"
; the LUT is defined in SBox.asm
!xtime = "TAY : LDA XTime,y"

; wrecks A,X,Y,!_+0,!_+1
MixColumns:
    LDX #$0C
    .mainloop
        ; X is to-be-mixed column number, left shifted twice
        LDA !state+0,x
        STA !_+0
        EOR !state+1,x
        EOR !state+2,x
        EOR !state+3,x
        STA !_+1

        !i #= 0
        while !i < 3
            LDA !state+!i,x
            EOR !state+!i+1,x
            !xtime
            EOR !_+1
            EOR !state+!i,x
            STA !state+!i,x
            !i #= !i+1
        endif

        LDA !state+3,x
        EOR !_+0
        !xtime
        EOR !_+1
        EOR !state+3,x
        STA !state+3,x

    DEX
    DEX
    DEX
    DEX
    BPL .mainloop
    RTS

