cow_enable_timeout .ds 2
COW_TIMEOUT = $0200


hide_cow:
    lda #SPRITE_COW_BIT
    eor #$ff
    and SPRITE_MASK
    sta SPRITE_MASK
    rts


show_cow:
    lda #SPRITE_COW_BIT
    ora SPRITE_MASK
    sta SPRITE_MASK
    rts


; sets Z if not visible
is_cow_visible:
    lda SPRITE_MASK
    and #SPRITE_COW_BIT
    rts


reset_cow:
    lda #>COW_TIMEOUT
    sta cow_enable_timeout+1
    lda #<COW_TIMEOUT
    sta cow_enable_timeout+0

    jsr hide_cow

    lda #COW_START_X
    sta SPRITE_3_X
    lda #COW_START_Y
    sta SPRITE_3_Y

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
    jsr show_cow

.update_cow_timeout_ret:
    rts


update_cow:
    jsr update_cow_timeout
    cmp #1
    bne .return

    ; check if cow is visible
    jsr is_cow_visible
    beq .return ; cow invisible

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

    lda #%00001000
    and SPRITE_3_X
    beq .return
    inc SPRITE_3_Y

.return
    rts
