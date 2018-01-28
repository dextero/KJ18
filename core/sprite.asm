


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

 ; pociag
    lda #$00
    sta $d02a

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

    lda #GEAR_SPRITE_DATA + 3
    sta $07fb

    ; enable sprite 
    lda #%0001111
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

    ; ustaw krowke
    lda #$20
    sta SPRITE_3_X

    lda #$60
    sta SPRITE_3_Y

    ;ustaw pociag
    lda #150
    sta $d006
    lda #180
    sta $d007

    ; scale 
    lda #%00001110
    sta $d017
    sta $d01d

    ; set multicolor
    lda #%00001110
    sta $d01c

    rts

clear_sprites:
    lda #$00
    sta $d015
    rts