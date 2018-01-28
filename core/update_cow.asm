cow_enable_timeout .ds 2
border_color_timeout .ds 1
prev_border_color .ds 1
COW_TIMEOUT = $0200


flash_border:
    ; red flash on border
    lda $d020
    sta prev_border_color
    and #$f0
    ora #$02
    sta $d020

    ; 15 ticks = 0.3s
    lda #15
    sta border_color_timeout
    rts


restore_border:
    lda prev_border_color
    sta $d020
    rts


hide_cow:
    lda #SPRITE_COW_BIT ^ $ff
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


zoom_cow:
    lda #SPRITE_COW_BIT
    ora SPRITE_DOUBLE_WIDTH
    sta SPRITE_DOUBLE_WIDTH
    lda #SPRITE_COW_BIT
    ora SPRITE_DOUBLE_HEIGHT
    sta SPRITE_DOUBLE_HEIGHT
    rts


shrink_cow:
    lda #SPRITE_COW_BIT ^ $ff
    and SPRITE_DOUBLE_WIDTH
    sta SPRITE_DOUBLE_WIDTH
    lda #SPRITE_COW_BIT ^ $ff
    and SPRITE_DOUBLE_HEIGHT
    sta SPRITE_DOUBLE_HEIGHT
    rts


reset_cow:
    lda #>COW_TIMEOUT
    sta cow_enable_timeout+1
    lda #<COW_TIMEOUT
    sta cow_enable_timeout+0

    jsr hide_cow
    jsr shrink_cow

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


update_flash_timeout:
    lda border_color_timeout
    cmp #0
    beq .update_flash_timeout_ret

    dec border_color_timeout
    bne .update_flash_timeout_ret

    jsr restore_border

.update_flash_timeout_ret
    rts


update_cow:
    jsr update_flash_timeout
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
    jsr flash_border

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
    lda #COW_START_Y+SCREEN_LINE_SIZE_PIX/8/2
    cmp SPRITE_3_Y
    bcs .return

    jsr zoom_cow

.return
    rts
