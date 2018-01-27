; =======================
; /entry/   =============

text_mode:

    ; enter text mode
    lda #$1b
    sta $d011 

    ; single color
    lda #$8
    sta $d016

    ; set default character set
    lda #$14
    sta $d018

    rts