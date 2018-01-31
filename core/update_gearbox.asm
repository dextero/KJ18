; Updates gearbox state
; offsets gear lever sprite

; =======================
; /entry/   =============

update_gearbox:
    ; check if the joystick state changed
    lda #%10000000
    sta CIA1_DATA_DIR_REG_A

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