;=========================
; /entry/ ================

highscore_screen:
    ; set colors
    text_color TEXT_COLOR
    text_bgcolor TEXT_BGCOLOR

    jsr text_mode

    ; clear screen
    jsr $e544

    ; setup font position
    lda #$16
    sta $d018

    move_cursor (40-#highscore_msg_size)/2, 9
    write highscore_msg, highscore_msg_size

    move_cursor (40-#your_score_msg_1_size)/2, 11
    write your_score_msg_1, your_score_msg_1_size

    move_cursor (40-5)/2, 13
    lda TIMER_ELAPSED_JIFFIES_HI
    ldx TIMER_ELAPSED_JIFFIES_LO
    jsr $bdcd

    move_cursor (40-#your_score_msg_2_size)/2, 15
    write your_score_msg_2, your_score_msg_2_size

    ldx #$00
.setcolor:
    lda #TEXT_BGCOLOR
    sta $d800,x
    inx
    cpx #highscore_msg_size
    bne .setcolor

    wait_for_key KEY_SPACE

    rts
