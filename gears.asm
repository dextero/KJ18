	processor	6502
	org	$1000

; //// consts

JOYSTICK_ADDR  = $DC00

CONTROL_REG_1 = $d011
CONTROL_REG_2 = $d016

GEAR_SPRITE_DATA = $80
GEAR_LEVER_CENTER_X = $25
GEAR_LEVER_CENTER_Y = $D6

GEAR_OFFSET = 16

; //// variables

JOYSTICK_STATE = 2048
SPACE_STATE = 2049
CURRENT_SHIFTER_POS = 2050

GEAR_LEVER_X = $d000
GEAR_LEVER_Y = $d001

; /////////////////
; //// program ////
; /////////////////

init:
	; setup graphics mode
	jsr enter_standard_bitmap_mode

init_gear_sprite:
	; load sprite
	lda #GEAR_SPRITE_DATA ; 80 * 40sprite_widyth = 2000
	sta $07f8

	; enable gear sprite sprite
	lda #$01
	sta $d015

init_gear_position:
	; set position
	lda #GEAR_LEVER_CENTER_X
	sta GEAR_LEVER_X

	lda #GEAR_LEVER_CENTER_Y
	sta GEAR_LEVER_Y

init_gear_state
	; setup gearshifter
	lda #$04 ; center gear
	sta CURRENT_SHIFTER_POS 

main:
	; main program

	jsr read_space

	; if the space is pressed, we update the gears
	lda SPACE_STATE
	cmp #0
	beq move

	jsr update_gearbox

move:
	jmp main


; //// update gearbox counter
update_gearbox:
	; check if the joystick state changed
	lda JOYSTICK_ADDR
	cmp JOYSTICK_STATE
	beq return

	; remember joystick state
	sta JOYSTICK_STATE

handle_up:
	lda #%00000001 ; mask joystick up movement 
	bit $dc00      ; bitwise AND with address 56320
	bne handle_down

	lda CURRENT_SHIFTER_POS 
	sec
	sbc #$03
	bmi handle_down
	sta CURRENT_SHIFTER_POS

	; update lever sprite
	lda GEAR_LEVER_Y
	sec
	sbc #GEAR_OFFSET
	sta GEAR_LEVER_Y


handle_down:

	lda #%00000010 ; mask joystick up movement 
	bit $dc00      ; bitwise AND with address 56320
	bne handle_left

	lda CURRENT_SHIFTER_POS 
	sec
	sbc #$06
	bpl handle_left

	clc
	adc #$09
	sta CURRENT_SHIFTER_POS

	; update lever sprite
	lda GEAR_LEVER_Y
	clc
	adc #GEAR_OFFSET
	sta GEAR_LEVER_Y

handle_left:
	lda #%00000100 ; mask joystick up movement 
	bit $dc00      ; bitwise AND with address 56320
	bne handle_right

	lda CURRENT_SHIFTER_POS 
	cmp #$04
	beq shift_left
	cmp #$05
	bne handle_right

shift_left:
	dec CURRENT_SHIFTER_POS 

	; update lever sprite
	lda GEAR_LEVER_X
	sec
	sbc #GEAR_OFFSET
	sta GEAR_LEVER_X

handle_right:
	lda #%00001000 ; mask joystick up movement 
	bit $dc00      ; bitwise AND with address 56320
	bne return

	lda CURRENT_SHIFTER_POS 
	cmp #$03
	beq shift_right
	cmp #$04
	bne return

shift_right:
	inc CURRENT_SHIFTER_POS 

	lda GEAR_LEVER_X
	clc
	adc #GEAR_OFFSET
	sta GEAR_LEVER_X

return: 
	rts

; //// check space key
read_space:

PORT_A = $dc00
PORT_B = $dc01

	sei

	lda #%11111111  ; CIA#1 port A = outputs 
	sta $dc02       ; CIA#1 (Data Direction Register A)            

	lda #%00000000  ; CIA#1 port B = inputs
	sta $dc03       ; CIA#1 (Data Direction Register B)          
	
	; operations
	lda #%01111111  ; column 
	sta PORT_A  

	; clear space
	lda #$00
	sta SPACE_STATE 

	lda PORT_B 
	and #%00010000  ; row
	bne ret_read_space

	lda #$01
	sta SPACE_STATE

ret_read_space:
	cli
	rts

; //////////////////////
; //// outside code ////
; //////////////////////

enter_standard_bitmap_mode:
	; https://www.c64-wiki.com/wiki/Standard_Bitmap_Mode
	lda CONTROL_REG_1
	and #%10111111 ; clear bit 6
	sta CONTROL_REG_1

	lda CONTROL_REG_2
	ora #%00100000 ; set bit 5
	sta CONTROL_REG_2

	rts


; //////////////
; //// data ////
; //////////////

	org $2000
	incbin "gear_knob.spr"