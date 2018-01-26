    processor 6502
    org $1000

BG_COLOR = $d021

CONTROL_REG_1 = $d011
CONTROL_REG_2 = $d016

STACK = $100

SCREEN = $400
SCREEN_LO = $00
SCREEN_HI = $04

SCREEN_PTR_LO = $2B
SCREEN_PTR_HI = $2C
SCREEN_LINE_ITERATOR = $2D

SCREEN_LINE_SIZE_B = 40
SCREEN_NUM_LINES = 25


main:
    jsr enter_standard_bitmap_mode

    ldy #1

loop:
    jsr draw_vertical_line
    inc BG_COLOR
    jmp loop


enter_standard_bitmap_mode:
    ; https://www.c64-wiki.com/wiki/Standard_Bitmap_Mode
    lda CONTROL_REG_1
    and #%10111111 ; clear bit 6
    sta CONTROL_REG_1

    lda CONTROL_REG_2
    ora #%00100000 ; set bit 5
    sta CONTROL_REG_2

    rts


draw_vertical_line:
    ; args: Y = X coordinate * 8

    ; setup screen ptr
    lda #SCREEN_LO
    sta SCREEN_PTR_LO
    lda #SCREEN_HI
    sta SCREEN_PTR_HI

    ; i = 0
    lda #0
    sta SCREEN_LINE_ITERATOR

    ; while (true) {
draw_vertical_line_loop:
    ;     *screen_ptr = 0xFF
    lda #$ff
    sta (SCREEN_PTR_LO),Y

    ;     screen_ptr += line_size
    lda SCREEN_PTR_LO
    clc
    adc #SCREEN_LINE_SIZE_B
    sta SCREEN_PTR_LO

    bcc draw_vertical_line_skip_inc
    inc SCREEN_PTR_HI

draw_vertical_line_skip_inc:
    ;     if (++i == num_lines) {
    ;        break;
    ;     }
    inc SCREEN_LINE_ITERATOR
    lda SCREEN_LINE_ITERATOR
    cmp #SCREEN_NUM_LINES
    bne draw_vertical_line_loop

    ; }
    rts
