; =======================
; /entry/   =============

multicolor_mode:

    lda #$3b
    sta $d011 

    lda #$18
    sta $d016

    ; setup bitmap offset
    lda #$10|BITMAP/$400
    sta $d018
    rts
