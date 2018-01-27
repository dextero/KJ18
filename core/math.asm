; in: A
; out: abs(A)
abs:
    cmp #0
    bpl abs_ret

    eor #$ff ; poor man's ~x
    clc
    adc #1

abs_ret:
    rts


; normal binary division
; NUMERATOR = NUMERATOR / DENUMERATOR
; A = NUMERATOR % DENUMERATOR
; http://6502org.wikidot.com/software-math-intdiv
divide:
    LDA #0
    LDX #8
    ASL NUMERATOR
L1:
    ROL
    CMP DENUMERATOR
    BCC L2
    SBC DENUMERATOR
L2:
    ROL NUMERATOR
    DEX
    BNE L1

    rts
