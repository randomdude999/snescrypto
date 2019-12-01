
macro SubBytes(box)
    !i #= 0
    while !i < 16
        LDX !state+!i
        LDA <box>,x
        STA !state+!i
        !i #= !i+1
    endif
endmacro

; performs SubBytes on !state
; wrecks AX
SubBytes:
    %SubBytes(SBox)
    RTS

; performs inverse of SubBytes in !state
; wrecks AX
InvSubBytes:
    %SubBytes(RSBox)
    RTS
