;=========================
; /entry/ ================

title_screen:
    ; set colors
    text_color TEXT_COLOR
    text_bgcolor TEXT_BGCOLOR

    jsr text_mode

    ; clear screen
    jsr $e544

    ; setup font position
    lda #$16 
    sta $d018


    lda title_screen_msg
    jsr draw_screen_text

    jsr wait_for_space
    rts


; main address from A
draw_screen_text: 
    
    write title_screen_msg, 200
    write title_screen_msg + 200, 200
    write title_screen_msg + 400, 200
    write title_screen_msg + 600, 100

   

    rts

