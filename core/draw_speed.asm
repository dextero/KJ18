draw_speed:
    ; WTF IS GOING ON HERE
    ; WHY DOES THAT WORK WITH 240 AND 25
    clc
    ldx #240
    ldy #25
    jsr $fff0

    write speed_msg, speed_msg_size
    ; draw number
    LDA #$00
    LDX CURRENT_SPEED
    JSR $BDCD

    ; lol
    write spaces, spaces_size

    rts
