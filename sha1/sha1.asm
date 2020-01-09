
; currently like 34 bytes of scratch
!_ = $00

; something (28 bytes)
!state = $0100

; internal
!count = !state+20

; something else (64 bytes)
!block = $0200

; set to 'speed' to use an unrolled transform function.
; Variant | Code size | Cycles | Scanlines (SNES SlowROM)
; --------+-----------+--------+-----------
; speed   | 12051     | 24494  | 148
; size    | 1707      | 39720  | 240
; Cycles is number of CPU cycles to run one transform, which is the majority
; of time spent when hashing a block (64 bytes of data). The exact timing
; depends on the exact length of the data, for ex. 56 bytes (smallest input
; that causes 2 blocks to be hashed) takes around 2650 extra cycles.
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
