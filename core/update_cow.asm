update_cow:

    inc SPRITE_3_X

    lda COW_UNDERFLOW
    clc
    adc CURRENT_SPEED
    sta COW_UNDERFLOW

    bcc .return

    inc SPRITE_3_Y

.return
    rts