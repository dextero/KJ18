
init_sprite:

    ; sprite base colors
    lda #4
    sta $d027

    lda #$00
    sta $d028

    ; sprite multi colors
    lda #15
    sta $d025

    lda #11
    sta $d026

    ; load sprite
    lda #GEAR_SPRITE_DATA 
    sta $07f8

    lda #GEAR_SPRITE_DATA + 1
    sta $07f9

    ; enable gear sprite sprite
    lda #%0000011
    sta $d015

    ; set position
    lda #GEAR_LEVER_CENTER_X
    sta GEAR_LEVER_X	; sprite 1

    sec
    sbc #12
    sta $d002			; sprite 2

    lda #GEAR_LEVER_CENTER_Y
    sta GEAR_LEVER_Y	; sprite 1

    sec
    sbc #12
    sta $d003			; sprite 2

    ; scale 
    lda #%00000010
    sta $d017
    sta $d01d

    ; set multicolor
    lda #%00000010
    sta $d01c

    rts



clear_sprites:
    lda #$00
    sta $d015
    rts