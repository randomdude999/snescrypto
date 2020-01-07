
; currently like 28 bytes of scratch
!_ = $00

; something (28 bytes)
!state = $0100

; internal
!count = !state+20

; something else (64 bytes)
!block = $0200

; set to 'speed' to use an unrolled transform function. this takes 11KB of ROM space (instead of 1.7KB for the size-optimized version), but takes 170 scanlines to do a block instead of X scanlines for the size-optimized one.
!optimize = size

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
