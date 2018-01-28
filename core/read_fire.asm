read_fire:

	lda #%00010000 ; mask joystick button push 
	bit $dc00      ; bitwise AND with address 56320
	bne .return_fire     ; button not pressed 
	
	lda #01
	sta JOYSTICK_FIRE
	rts

.return_fire
	lda #00
	sta JOYSTICK_FIRE
	rts            ; back to basic