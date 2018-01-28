;//////////////////////////////////////////////////////////
;// Loads an image to screen VRAM (0400), from default save position
;// - data 
;// - ...
;//////////////////////////////////////////////////////////

`
load_background:
    ; load color
    lda $4710
    sta $d020
    sta $d021

    ldx #$00
.loaddccimage:
    lda $3f40,x
    sta $0400,x
    lda $4040,x
    sta $0500,x
    lda $4140,x
    sta $0600,x
    lda $4240,x
    sta $0700,x
    lda $4328,x
    sta $d800,x
    lda $4428,x
    sta $d900,x
    lda $4528,x
    sta $da00,x
    lda $4628,x
    sta $db00,x
    inx
    bne .loaddccimage

    lda #$18
    sta $d018

    rts