;=========================
; /entry/ ================

creators_screen:
    jsr set_bank_two

    ; set multicolor mode
    lda #$3b
    sta $d011
    lda #$18
    sta $d016
    lda #$18
    sta $d018

    ; set background colors
    lda $8710
    sta $d020
    sta $d021

    ; copy image
    ldx #$00
loaddccimage:
    lda $7f40,x
    sta $4400,x
    lda $8040,x
    sta $4500,x
    lda $8140,x
    sta $4600,x
    lda $8240,x 
    sta $4700,x
    lda $8328,x
    sta $d800,x
    lda $8428,x
    sta $d900,x
    lda $8528,x
    sta $da00,x
    lda $8628,x
    sta $db00,x
    inx
    bne loaddccimage

wait:
    jsr read_space
    lda SPACE_STATE
    cmp #00
    beq wait

    jsr set_bank_one
    jsr text_mode

    rts

    