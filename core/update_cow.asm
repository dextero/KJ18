cow_enable_timeout .ds 2
COW_TIMEOUT = $0200


reset_cow:
    lda #>COW_TIMEOUT
    sta cow_enable_timeout+1
    lda #<COW_TIMEOUT
    sta cow_enable_timeout+0

    lda #0
    sta COW_VISIBLE

    rts


; returns: A = 1 if cow on timeout
;          A = 0 if cow active
update_cow_timeout:
    lda #0
    cmp cow_enable_timeout+1
    bne .update_cow_timeout_continue

    cmp cow_enable_timeout+0
    bne .update_cow_timeout_continue

    lda #1
    rts

.update_cow_timeout_continue:
    lda #0
    dec cow_enable_timeout+0
    bne .update_cow_timeout_ret
    dec cow_enable_timeout+1
    bne .update_cow_timeout_ret

    ; timeout == 0
    lda #0
    sta SPRITE_3_X
    lda #1
    sta COW_VISIBLE

.update_cow_timeout_ret:
    rts


update_cow:
    jsr update_cow_timeout
    cmp #1
    bne .return

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
    lda #$ff
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
