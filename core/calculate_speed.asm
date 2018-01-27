; =======================
; /entry/   =============


; X - min bound
; Y - max bound
accelerate_if_speed_between:
    cpx CURRENT_SPEED
    bcc .decelerate
    cpy CURRENT_SPEED
    bcs .decelerate

    lda #$ff
    cmp CURRENT_SPEED
    bne .accelerate

    ; already max speed
    rts

.accelerate:
    inc CURRENT_SPEED
    rts

.decelerate:
    dec CURRENT_SPEED
    rts


; if speed == 255, do nothing
; otherwise, if speed in [gear*44-GEAR_CHANGE_LEEWAY, (gear+1)*44+GEAR_CHANGE_LEEWAY] range
; otherwise, decelerate
calculate_speed:
	lda CURRENT_SHIFTER_POS

    cmp #$01
    bne .gear2
    ldx #0-GEAR_CHANGE_LEEWAY
    ldy #44+GEAR_CHANGE_LEEWAY
    jmp accelerate_if_speed_between

.gear2:
    cmp #$07
    bne .gear3
    ldx #44-GEAR_CHANGE_LEEWAY
    ldy #88+GEAR_CHANGE_LEEWAY
    jmp accelerate_if_speed_between

.gear3:
    cmp #$02
    bne .gear4
    ldx #88-GEAR_CHANGE_LEEWAY
    ldy #132+GEAR_CHANGE_LEEWAY
    jmp accelerate_if_speed_between

.gear4:
    cmp #$08
    bne .gear5
    ldx #132-GEAR_CHANGE_LEEWAY
    ldy #176+GEAR_CHANGE_LEEWAY
    jmp accelerate_if_speed_between

.gear5:
    cmp #$03
    bne .gear6
    ldx #176-GEAR_CHANGE_LEEWAY
    ldy #220+GEAR_CHANGE_LEEWAY
    jmp accelerate_if_speed_between

.gear6:
    cmp #$09
    bne .neutral
    ldx #220-GEAR_CHANGE_LEEWAY
    ldy #255
    jmp accelerate_if_speed_between

.neutral:
    dec CURRENT_SPEED
    rts
