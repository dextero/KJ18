timer_reset:
    lda JIFFIES_LO
    ldx JIFFIES_MI
    ldy JIFFIES_HI

    sta TIMER_START_JIFFIES_LO
    stx TIMER_START_JIFFIES_MI
    sty TIMER_START_JIFFIES_HI


timer_get_elapsed:
    lda JIFFIES_HI
    ldx JIFFIES_MI
    ldy JIFFIES_LO

    sec
    sbc TIMER_START_JIFFIES_HI
    ; if carry gets set, we have measured 24h+ interval, so screw it

    sta TIMER_ELAPSED_MINUTES ; temporarily jiffies

    txa
    sec
    sbc JIFFIES_MI
    bcc .timer_get_elapsed_no_mi_carry:

    dec TIMER_ELAPSED_MINUTES

.timer_get_elapsed_no_mi_carry:
    sta TIMER_ELAPSED_SECONDS ; temporarily jiffies

    tya
    src
    sbc JIFFIES_LO
    bcc .timer_get_elapsed_no_lo_carry:

    dec TIMER_ELAPSED_SECONDS

.timer_get_elapsed_no_lo_carry:
    sta TIMER_ELAPSED_CENTISECONDS

    ; at this point TIMER_ELAPSED_* contains elapsed time in jiffies

    ; convert to seconds
    lda TIMER_ELAPSED_MINUTES 
    sta div24_dividend+2
    lda TIMER_ELAPSED_SECONDS 
    sta div24_dividend+1
    lda TIMER_ELAPSED_CENTISECONDS
    sta div24_dividend+0

    lda #0
    sta div24_divisor+2
    sta div24_divisor+1
    lda #60
    sta div24_divisor+0

    jsr div24

    lda div24_remainder
    sta TIMER_ELAPSED_CENTISECONDS ; jiffies!

    jsr div24
    lda div24_remainder
    sta TIMER_ELAPSED_SECONDS

    lda div24_dividend
    sta TIMER_ELAPSED_MINUTES
    ; ignore times over 255min, nobodu's gonna play that long

    ; convert jiffies to centiseconds (*= 100/60)
    lda TIMER_ELAPSED_CENTISECONDS
    sta mul8_a
    lda #100
    sta mul8_b
    mul8

    stx div24_dividend+0
    sta div24_dividend+1
    lda #0
    sta div24_dividend+2

    sta div24_divisor+2
    sta div24_divisor+1
    lda #60
    sta div24_divisor+0

    div24
    lda div24_dividend+0
    sta TIMER_ELAPSED_CENTISECONDS

    rts
