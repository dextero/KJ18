


update_tree:

	;check if enabled
	lda #%00100000
	and $d015
	cmp #00
	beq .check

    lda TREE_UNDERFLOW
    clc
    adc CURRENT_SPEED
    sta TREE_UNDERFLOW

    bcc .return_tree

    inc SPRITE_TREE_Y
    inc SPRITE_TREE_Y
	dec SPRITE_TREE_X

	lda SPRITE_TREE_Y
	sec
	sbc #180
	bne .return_tree

.hide
	lda #%00100000^$ff
	and $d015
	sta $d015
	rts

.check
	lda TIMER_LO
	cmp #4
	bne .return_tree

	lda #%00100000
	ora $d015
	sta $d015

	lda #100
    sta $d00a
    lda #70
    sta $d00b

.return_tree
    rts

