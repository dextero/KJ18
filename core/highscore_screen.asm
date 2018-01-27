;=========================
; /entry/ ================

highscore_screen:
    ; set colors
    lda #TITLE_BCG
    sta $d020
    lda #TITLE_BORDER
    sta $d021

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
    lda #TITLE_BCG
    sta $d800,x
    inx
    cpx #highscore_msg_size
    bne .setcolor

    jsr wait_for_space

    rts

    