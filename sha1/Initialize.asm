SHA1Initialize:
    LDA #$2301
    STA !state+0
    LDA #$6745
    STA !state+2
    LDA #$AB89
    STA !state+4
    LDA #$EFCD
    STA !state+6
    LDA #$DCFE
    STA !state+8
    LDA #$98BA
    STA !state+10
    LDA #$5476
    STA !state+12
    LDA #$1032
    STA !state+14
    LDA #$E1F0
    STA !state+16
    LDA #$C3D2
    STA !state+18
    ; reset byte counter
    STZ !state+20
    STZ !state+22
    STZ !state+24
    STZ !state+26
    RTS
