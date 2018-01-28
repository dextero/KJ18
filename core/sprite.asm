
; 0 - lever     (x: d000,y: d0001)
; 1 - gearbox   (x: d002,y: d0003)
; 2 - cow       (x: d004,y: d0005)
; 3 - train     (x: d006,y: d0007)
; 4 - gear bcg  (x: d008,y: d0009)
; 5 - tree      (x: d00a,y: d000b)

init_sprite:

    ; sprite multi colors
    lda #15
    sta $d025

    lda #11
    sta $d026
	
    ; enable sprite 
    lda #%1111111
    sta $d015

	; scale 
    lda #%00111110
    sta $d017
    sta $d01d

    ; set multicolor
    lda #%00001100
    sta $d01c

	jsr .load_sprites
	jsr .set_positions
	jsr .set_base_colors
    rts

clear_sprites:
    lda #$00
    sta $d015
    rts


.set_base_colors:
    ; lever
    lda #6
    sta $d027

    ; gearbox
    lda #00
    sta $d028

    ; krowka
    lda #01
    sta $d029

	; pociag
    lda #00
    sta $d02a

	; gearbcg
    lda #12
    sta $d02b

	; tree
    lda #9
    sta $d02c
	rts

.load_sprites:
    lda #GEAR_SPRITE_DATA 
    sta $07f8

    lda #GEAR_SPRITE_DATA + 1
    sta $07f9

    lda #GEAR_SPRITE_DATA + 2
    sta $07fa

    lda #GEAR_SPRITE_DATA + 3
    sta $07fb

	lda #GEAR_SPRITE_DATA + 4
    sta $07fc

	lda #GEAR_SPRITE_DATA + 5
    sta $07fd
	rts

.set_positions
	lda #GEAR_LEVER_CENTER_X
    sta GEAR_LEVER_X	; sprite 1

    sec
    sbc #12
    sta SPRITE_2_X
	sta $d008

    lda #GEAR_LEVER_CENTER_Y
    sta GEAR_LEVER_Y	

    sec
    sbc #12
    sta SPRITE_2_Y		
	sta $d009

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

	;ustaw tree
    lda #150
    sta $d00a
    lda #120
    sta $d00b

	rts
