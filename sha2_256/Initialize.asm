SHA256Initialize:
    REP #$30
    LDX #SHA256InitialVals
    BRA SHA224Initialize_common

SHA224Initialize:
    REP #$30
    LDX #SHA224InitialVals
.common:
    LDY #!state
    LDA.w #63
    MVN $00,SHA256Initialize>>16
    STZ !count
    STZ !count+2
    STZ !count+4
    STZ !count+6
    RTS

SHA256InitialVals:
dd $6a09e667
dd $bb67ae85
dd $3c6ef372
dd $a54ff53a
dd $510e527f
dd $9b05688c
dd $1f83d9ab
dd $5be0cd19

SHA224InitialVals:
dd $c1059ed8
dd $367cd507
dd $3070dd17
dd $f70e5939
dd $ffc00b31
dd $68581511
dd $64f98fa7
dd $befa4fa4
