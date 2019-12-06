
; currently like 28 bytes of scratch
!_ = $00

; something (28 bytes)
!state = $0100

; internal
!count = !state+20

; something else (64 bytes)
!block = $0200

incsrc Transform.asm
incsrc Initialize.asm
incsrc Update.asm
