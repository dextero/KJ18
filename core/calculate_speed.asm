; =======================
; /entry/   =============

slowdown_counter .ds 1

noop:
    rts

accelerate:
    lda CURRENT_SPEED
    cmp #$ff
    beq noop

    inc slowdown_counter
    lda slowdown_counter
    cmp #SPEEDUP_FACTOR
    bne .accelerate_later

    lda #0
    sta slowdown_counter

    inc CURRENT_SPEED

.accelerate_later:
    rts


decelerate:
    lda CURRENT_SPEED
    cmp #$00
    beq noop

    dec slowdown_counter
    lda slowdown_counter
    cmp #-SLOWDOWN_FACTOR
    bne .decelerate_later

    lda #0
    sta slowdown_counter

    dec CURRENT_SPEED

.decelerate_later:
    rts


decelerate_quick:
    lda CURRENT_SPEED
    cmp #$00
    beq noop
    dec CURRENT_SPEED
    dec CURRENT_SPEED
    rts


; X - min bound
; Y - max bound
accelerate_if_speed_between:
    cpx CURRENT_SPEED
    beq .equal
    bcs decelerate ; >=
.equal:
    cpy CURRENT_SPEED
    bcc decelerate_quick ; engine braking

    lda #$ff
    cmp CURRENT_SPEED
    bne accelerate

    ; already max speed
    rts


; if speed in [gear*44-GEAR_CHANGE_LEEWAY, (gear+1)*44+GEAR_CHANGE_LEEWAY] range, accelerate
; BUT if speed == 255 and would accelerate OR speed == 0 and would decelerate, do nothing
; otherwise, decelerate
calculate_speed:
    lda JOYSTICK_FIRE
    beq .clutch_up

    jmp decelerate

.clutch_up:
	lda CURRENT_SHIFTER_POS

    cmp #$00
    bne .gear2
    ldx #0
    ldy #44+GEAR_CHANGE_LEEWAY
    jmp accelerate_if_speed_between

.gear2:
    cmp #$06
    bne .gear3
    ldx #44-GEAR_CHANGE_LEEWAY
    ldy #88+GEAR_CHANGE_LEEWAY
    jmp accelerate_if_speed_between

.gear3:
    cmp #$01
    bne .gear4
    ldx #88-GEAR_CHANGE_LEEWAY
    ldy #132+GEAR_CHANGE_LEEWAY
    jmp accelerate_if_speed_between

.gear4:
    cmp #$07
    bne .gear5
    ldx #132-GEAR_CHANGE_LEEWAY
    ldy #176+GEAR_CHANGE_LEEWAY
    jmp accelerate_if_speed_between

.gear5:
    cmp #$02
    bne .gear6
    ldx #176-GEAR_CHANGE_LEEWAY
    ldy #220+GEAR_CHANGE_LEEWAY
    jmp accelerate_if_speed_between

.gear6:
    cmp #$08
    bne .neutral
    ldx #220-GEAR_CHANGE_LEEWAY
    ldy #255
    jmp accelerate_if_speed_between

.neutral:
    jmp decelerate


get_gear_num:
    ldx CURRENT_SHIFTER_POS
    cpx #0
    beq .get_gear_num_gear1
    cpx #1
    beq .get_gear_num_gear3
    cpx #2
    beq .get_gear_num_gear5
    cpx #6
    beq .get_gear_num_gear2
    cpx #7
    beq .get_gear_num_gear4
    cpx #8
    beq .get_gear_num_gear6

    ;neutral
    lda #0
    rts

.get_gear_num_gear1:
    lda #1
    rts
.get_gear_num_gear2:
    lda #2
    rts
.get_gear_num_gear3:
    lda #3
    rts
.get_gear_num_gear4:
    lda #4
    rts
.get_gear_num_gear5:
    lda #5
    rts
.get_gear_num_gear6:
    lda #6
    rts


; returns: A - estimation of RPM / 100 
get_rpm_x100:
    jsr get_gear_num
    tax
    tay

    cpx #0
    beq .get_rpm_x100_zero

    lda CURRENT_SPEED

.get_rpm_x100_loop:
    dex
    beq .get_rpm_x100_break

    cmp #44
    bcc .get_rpm_x100_zero

    sec
    sbc #44
    jmp .get_rpm_x100_loop

.get_rpm_x100_zero:
    lda #0

.get_rpm_x100_break:
    cpy #2
    bcc .get_rpm_x100_ret

    lsr
    clc
    adc #22

.get_rpm_x100_ret:
    rts
