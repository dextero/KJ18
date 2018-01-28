DISTANCE_TRAVELED .ds 4

reset_distance_traveled:
    lda #0
    sta DISTANCE_TRAVELED+0
    sta DISTANCE_TRAVELED+1
    sta DISTANCE_TRAVELED+2
    sta DISTANCE_TRAVELED+3
    rts

; updates DISTANCE_TRAVELED according to current SPEED
; MUST be called in regular intervals (from an IRQ handler)
update_distance_traveled:
    lda CURRENT_SPEED
    clc
    adc DISTANCE_TRAVELED+0
    sta DISTANCE_TRAVELED+0
    lda #0
    adc DISTANCE_TRAVELED+1
    sta DISTANCE_TRAVELED+1
    lda #0
    adc DISTANCE_TRAVELED+2
    sta DISTANCE_TRAVELED+2
    lda #0
    adc DISTANCE_TRAVELED+3
    sta DISTANCE_TRAVELED+3

    rts


; checks if the finish line was reached.
; returns: A = 1 if finished, A = 0
is_finish_line_reached:
    lda DISTANCE_TRAVELED+3
    cmp #>FINISH_LINE_POS_HI
    bcc .not_finished ; >HI less
    bne .finished

    lda DISTANCE_TRAVELED+2
    cmp #<FINISH_LINE_POS_HI
    bcc .not_finished ; <HI less
    bne .finished

    ; HI equal
    lda DISTANCE_TRAVELED+1
    cmp #>FINISH_LINE_POS_LO
    bcc .not_finished ; >LO less
    bne .finished

    ; HI:MI equal
    lda DISTANCE_TRAVELED+0
    cmp #<FINISH_LINE_POS_LO
    bcc .not_finished ; <LO less
    bne .finished

    ; HI:MI:LO equal

.finished:
    lda #1
    rts

.not_finished:
    lda #0
    rts
