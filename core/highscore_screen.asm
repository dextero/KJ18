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

    move_cursor 10, 5
    write highscore_msg, highscore_msg_size

    lda TIMER_ELAPSED_JIFFIES_HI
    jeq .highscore_print

    ; oh fuck, a 3-byte number of jiffies
    ; how does one print that?
    ; insult the player instead
    move_cursor 10, 7
    write lowscore_msg, lowscore_msg_size

    jmp .highscore_skip_print

.highscore_print:
    move_cursor 10, 7
    write your_score_msg_1, your_score_msg_1_size

    lda TIMER_ELAPSED_JIFFIES_MI
    ldx TIMER_ELAPSED_JIFFIES_LO
    jsr $bdcd

    write your_score_msg_2, your_score_msg_2_size

.highscore_skip_print:

    ldx #$00
.setcolor:
    lda #TEXT_BGCOLOR
    sta $d800,x
    inx
    cpx #highscore_msg_size
    bne .setcolor

    jsr wait_for_space

    rts
