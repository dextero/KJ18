; NOTE: USE is_key_down MACRO INSTEAD!
; see Keyboard Map @ https://www.c64-wiki.com/wiki/Keyboard
; inputs: X - column
;         Y - row
; output: Z set if key down, clear if up
is_key_down_impl subroutine
    sei

    lda #$ff
    sta CIA1_DATA_DIR_REG_A
    lda #$00
    sta CIA1_DATA_DIR_REG_B

    stx CIA1_PORT_REG_A
    tya
    and CIA1_PORT_REG_B

    cli
    rts

; arguments - KEY_ constant (see above)
; outputs: Z set if key down, clear if up
    mac is_key_down

.set A = ({1} >> 3) % %000111
.set B = ({1} >> 0) % %000111

    ldy #A
    ldx #B
    is_key_down

    endm
