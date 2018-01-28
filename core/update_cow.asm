reset_cow:
    lda #0
    sta SPRITE_3_X

    lda #1
    sta COW_VISIBLE

    rts


update_cow:
    ; check if cow is visible
    lda COW_VISIBLE
    cmp #00
    beq .return

    inc SPRITE_3_X

    ; add bit to 255+ movement
    ; check if cow moved safely
    lda #SCREEN_LINE_SIZE_PIX/2
    cmp SPRITE_3_X
    bcs .continue

    lda #SCREEN_LINE_SIZE_PIX/2+COW_SPRITE_SIZE
    cmp SPRITE_3_X
    bcc .no_collision

    lda CURRENT_SPEED
    cmp #LETHAL_SPEED
    bcc .no_collision

    ; collision
    lda #0
    sta CURRENT_SPEED
    jsr reset_cow
    jmp .return

.no_collision:
    ; HACK
    lda #<SCREEN_LINE_SIZE_PIX-1
    cmp SPRITE_3_X
    bne .continue

    jsr reset_cow

.continue
    lda COW_UNDERFLOW
    clc
    adc CURRENT_SPEED
    sta COW_UNDERFLOW

    bcc .return

    inc SPRITE_3_Y

    ; check if cow collided with train

.return
    rts
