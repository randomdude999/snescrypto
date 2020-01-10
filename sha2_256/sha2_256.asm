; scratch (~40 bytes perhaps)
!_ = $00

; internal state. 40 bytes
; Note: Should be accessible from bank 0 too, instead of current bank only because it's used by MVN
!state = $0100

; internal buffer for current block. 64 bytes
!block = $0200

; TODO: write both impls and check what the tradeoff is
!optimize = speed

!count = !state+32
if stringsequal("!optimize","size")
    incsrc TransformSmall.asm
elseif stringsequal("!optimize","speed")
    incsrc TransformFast.asm
else
    error "invalid value of \!optimize"
endif
incsrc Initialize.asm
incsrc Update.asm
incsrc Finalize.asm
