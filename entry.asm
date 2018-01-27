    processor 6502
    org $1000

; =======================
; /consts/ ===============

CONTROL_REG_1 = $d011
CONTROL_REG_2 = $d016

PORT_A = $dc00
PORT_B = $dc01

JOYSTICK_ADDR  = $DC00

COLOR_MODE_RASTER = 220

GEAR_SPRITE_DATA = $80
GEAR_LEVER_CENTER_X = $25
GEAR_LEVER_CENTER_Y = $D6

GEAR_OFFSET = 16

; =======================
; /variables/ ===========

CURRENT_SPEED = 2051;
CURRENT_SHIFTER_POS = 2050

JOYSTICK_STATE = 2048
SPACE_STATE = 2049

GEAR_LEVER_X = $d000
GEAR_LEVER_Y = $d001

; =======================
; /init/ ================

    ;speed
    lda #0
    sta CURRENT_SPEED

    ;shifter
    lda #$04 
    sta CURRENT_SHIFTER_POS 

    ;sprite
    lda #GEAR_LEVER_CENTER_X
    sta GEAR_LEVER_X

    lda #GEAR_LEVER_CENTER_Y
    sta GEAR_LEVER_Y


; =======================
; /methods/   ===========

main: 

	jsr split_screen
    
loop:

    jmp loop
    rts

; =======================
; /includes/ ============
	include "core/split_screen.asm"
	include "core/init_interupts.asm"
	include "core/multicolor_mode.asm"
	include "core/text_mode.asm"

; =======================
; /data/ ================

speed_msg .byte "SPEED: ";

    org $2000
    incbin "content/gear_knob.spr"