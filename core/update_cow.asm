update_cow:

    ; check if cow is visible
    lda COW_VISIBLE
    cmp #00
    beq .return

    inc SPRITE_3_X


    ; add bit to 255+ movement
    ; check if cow moved safely


    lda COW_UNDERFLOW
    clc
    adc CURRENT_SPEED
    sta COW_UNDERFLOW

    bcc .return

    inc SPRITE_3_Y

    ; check if cow collided with train


.return
    rts