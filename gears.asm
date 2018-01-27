    processor	6502
    org	$1000

    include "core/memory.asm"

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
    incbin "content/gear_knob.spr"