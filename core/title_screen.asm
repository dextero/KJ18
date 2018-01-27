;=========================
; /entry/ ================

title_screen:
    ; set colors
    lda #$13
    sta $d020
    lda #$04
    sta $d021


    jsr text_mode

    ; clear screen
    jsr $e544

    ; setup font position
    lda #$16 
    sta $d018

    ldx #$00
write_title:      
    lda    title_msg,x
    jsr    $ffd2
    inx
    cpx    #40
    bne    write_title

    ldx #$00

setcolor:  
    lda #$13
    sta $d800,x
    inx
    cpx #$54
    bne setcolor

    rts

    