draw_speed:
	clc
	ldx #240
	ldy #25
	jsr $fff0

	ldx #$00
write:      
	lda    speed_msg,x
	jsr    $ffd2
	inx
	cpx    #7
	bne    write

	ldx #$00

	; draw number
	LDA #$00
	LDX CURRENT_SHIFTER_POS
	JSR $BDCD

	rts