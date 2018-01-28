


init_sprite:

    ; sprite base colors

    ; lever
    lda #4
    sta $d027

    ; gearbox
    lda #$00
    sta $d028

    ; krowka
    lda #$01
    sta $d029

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

    lda #GEAR_SPRITE_DATA + 2
    sta $07fa

    ; enable sprite 
    lda #%0000111
    sta $d015

    ; set position

    lda #GEAR_LEVER_CENTER_X
    sta GEAR_LEVER_X	; sprite 1

    sec
    sbc #12
    sta SPRITE_2_X

    lda #GEAR_LEVER_CENTER_Y
    sta GEAR_LEVER_Y	

    sec
    sbc #12
    sta SPRITE_2_Y		


    lda #$20
    sta SPRITE_3_X

    lda #$60
    sta SPRITE_3_Y

    ; scale 
    lda #%00000110
    sta $d017
    sta $d01d

    ; set multicolor
    lda #%00000110
    sta $d01c

    rts



clear_sprites:
    lda #$00
    sta $d015
    rts