wait_for_space:

.reset
	jsr read_space
	lda SPACE_STATE
	cmp #01
	beq .reset

.wait
	jsr read_space
	lda SPACE_STATE
	cmp #00
	beq .wait
	rts
