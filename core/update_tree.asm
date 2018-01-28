

update_tree:

    lda TREE_UNDERFLOW
    clc
    adc CURRENT_SPEED
    sta TREE_UNDERFLOW

    bcc .return_tree

    inc SPRITE_TREE_Y
    inc SPRITE_TREE_Y
	dec SPRITE_TREE_X

	lda SPRITE_TREE_X
	cmp #00
	bne .return_tree

	lda SPRITE_TREE_X
	cmp #220
	bne .return_tree

.hide
	inc $d021

.return_tree
    rts