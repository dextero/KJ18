draw_speed:
    clc
    ldx #22
    ldy #5
    jsr $fff0

    write speed_msg, speed_msg_size
    ; draw number
    LDA #$00
    LDX CURRENT_SPEED
    JSR $BDCD

    write spaces, spaces_size

    clc
    ldx #23
    ldy #5
    jsr $fff0

    write rpm_msg, rpm_msg_size
    ; draw number
    jsr get_rpm_x100
    tax
    lda #0
    JSR $BDCD

    write rpm_suffix, rpm_suffix_size
    write spaces, spaces_size

    rts
