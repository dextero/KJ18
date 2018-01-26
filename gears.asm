    processor	6502
    org	$1000

; //// definitions

JOYSTICK_ADDR  = $DC00


JOYSTICK_STATE = $d2000
SPACE_STATE = $d2001
CURRENT_SHIFTER_POS = $d2002

; /////////////////
; //// program ////
; /////////////////


init:
    lda #$04 ; center gear
    sta CURRENT_SHIFTER_POS 

main:
    ; main program

    jsr update_gearbox
    jsr read_space
    
    ; testing
    lda CURRENT_SHIFTER_POS
    sta $d020

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
