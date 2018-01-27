    processor	6502
    org	$1000

    include "core/memory.asm"

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
    jsr enter_standard_bitmap_mode

init_gear_sprite:
    ; load sprite
    lda #GEAR_SPRITE_DATA 
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
    beq goto_move       ; if we are not changing gears
    jsr update_gearbox  ; change gears
goto_move:
    jmp main

    include "core/space.asm"
    include "gameplay/update_gearbox.asm"

; //////////////////////
; //// outside code ////
; //////////////////////

enter_standard_bitmap_mode:
    ; https://www.c64-wiki.com/wiki/Standard_Bitmap_Mode
    lda #$3b
    sta $d011 
    lda #$18
    sta $d016

    rts

; //////////////
; //// data ////
; //////////////

    org $2000
    incbin "gear_knob.spr"