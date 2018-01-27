; =======================
; /entry/   =============

calculate_speed:
	lda CURRENT_SHIFTER_POS

	; handle neutral "gears"
	cmp #$04
	beq decelerate
	cmp #$05
	beq decelerate
	cmp #$06
	beq decelerate

accelerate:
	inc CURRENT_SPEED

decelerate:
	dec CURRENT_SPEED	
	rts
