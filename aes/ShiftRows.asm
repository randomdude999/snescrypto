function state(col,row) = 4*col+row+!state

macro ShiftRows(a,b)
    ; row 1 (or 3 in InvShiftRows)
    LDX state(0,<a>)
    LDA state(1,<a>)
    STA state(0,<a>)
    LDA state(2,<a>)
    STA state(1,<a>)
    LDA state(3,<a>)
    STA state(2,<a>)
    STX state(3,<a>)
    ; row 2
    LDX state(0,2)
    LDA state(2,2)
    STA state(0,2)
    STX state(2,2)
    LDX state(1,2)
    LDA state(3,2)
    STA state(1,2)
    STX state(3,2)
    ; row 3 (or 1)
    LDX state(3,<b>)
    LDA state(2,<b>)
    STA state(3,<b>)
    LDA state(1,<b>)
    STA state(2,<b>)
    LDA state(0,<b>)
    STA state(1,<b>)
    STX state(0,<b>)
endmacro

; performs ShiftRows on !state
; wrecks A,X
; timing: 24*3 (if state in DP) or 24*4 cycles per run, +12 calling overhead
ShiftRows:
    %ShiftRows(1,3)
    RTS

; performs inverse of ShiftRows on !state
; wrecks A,X
; timing: same as above blah blah blah
InvShiftRows:
    %ShiftRows(3,1)
    RTS
