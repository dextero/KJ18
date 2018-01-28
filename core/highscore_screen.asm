;=========================
; /entry/ ================

highscore_screen:
    ; set colors
    text_color TEXT_COLOR
    text_bgcolor TEXT_BGCOLOR

    jsr text_mode

    ; clear screen
    jsr $e544


    ; move cursor
    clc
    ldx #10
    ldy #15
    jsr $fff0

    ; setup font position
    lda #$16
    sta $d018

    ldx #$00
.write_title:
    lda    highscore_msg,x
    jsr    $ffd2
    inx
    cpx    #highscore_msg_size
    bne    .write_title

    ldx #$00

.setcolor:
    lda #TEXT_BGCOLOR
    sta $d800,x
    inx
    cpx #highscore_msg_size
    bne .setcolor

    jsr wait_for_space

    rts
