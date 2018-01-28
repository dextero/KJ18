TIMER_A_LO = $dc04
TIMER_A_HI = $dc05

timer_reset:
    lda TIMER_A_LO
    ldx TIMER_A_HI

    sta TIMER_START_JIFFIES_LO
    sty TIMER_START_JIFFIES_HI

    rts


; return jiffies (1/60 of a second) elapsed since timer_reset call
; result saved to TIMER_START_JIFFIES (3B, unsigned)
timer_get_elapsed:
    lda TIMER_A_LO
    ldx TIMER_A_HI

    sec
    sbc TIMER_START_JIFFIES_LO
    sta TIMER_ELAPSED_JIFFIES_LO
    txa
    sbc TIMER_START_JIFFIES_HI
    sta TIMER_ELAPSED_JIFFIES_HI

    rts
