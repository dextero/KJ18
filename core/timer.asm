timer_reset:
    lda JIFFIES_LO
    ldx JIFFIES_MI
    ldy JIFFIES_HI

    sta TIMER_START_JIFFIES_LO
    stx TIMER_START_JIFFIES_MI
    sty TIMER_START_JIFFIES_HI


; return jiffies (1/60 of a second) elapsed since timer_reset call
; result saved to TIMER_START_JIFFIES (3B, unsigned)
timer_get_elapsed:
    lda JIFFIES_LO
    ldx JIFFIES_MI
    ldy JIFFIES_HI

    sec
    sbc TIMER_START_JIFFIES_LO
    sta TIMER_ELAPSED_JIFFIES_LO
    txa
    sbc TIMER_START_JIFFIES_MI
    sta TIMER_ELAPSED_JIFFIES_MI
    tya
    sbc TIMER_START_JIFFIES_HI
    sta TIMER_ELAPSED_JIFFIES_HI

    rts
