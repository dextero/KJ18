    processor 6502
    org $1000

BG_COLOR = $d021

CONTROL_REG_1 = $d011
CONTROL_REG_2 = $d016

STACK = $100

SCREEN = $400
SCREEN_LO = $00
SCREEN_HI = $04

SCREEN_END_LO = $e8
SCREEN_END_HI = $07

SCREEN_PTR_LO = $2B
SCREEN_PTR_HI = $2C
SCREEN_LINE_ITERATOR = $2D

SCREEN_LINE_SIZE_B = 320/8
SCREEN_NUM_LINES = 200/8

RASTER_COUNTER = $d012


main:
    jsr enter_standard_bitmap_mode

    ldy #1

    jsr clear_screen
loop:
    jsr draw_vertical_line
    jsr sync_screen
    ;inc BG_COLOR
    jmp loop


sync_screen:
    lda RASTER_COUNTER
    cmp #$00
    bne sync_screen
    rts


screen_ptr_reset:
    lda #SCREEN_LO
    sta SCREEN_PTR_LO
    lda #SCREEN_HI
    sta SCREEN_PTR_HI
    rts


screen_ptr_valid:
    ; set A to 1 if SCREEN_PTR is still inside screen region
    ; or to 0 if it is not
    ; NOTE: reports addresses below SCREEN as correct
    lda SCREEN_PTR_HI
    cmp #SCREEN_END_HI

    ; unsigned compare!
    beq screen_ptr_valid_maybe
    bcc screen_ptr_valid_yup

screen_ptr_valid_maybe:
    lda SCREEN_PTR_LO
    cmp #SCREEN_END_LO

    bcc screen_ptr_valid_yup

screen_ptr_valid_nope:
    lda #0
    rts

screen_ptr_valid_yup:
    lda #1
    rts


screen_ptr_next_line:
    ; advance SCREEN_PTR to next line
    ;
    ; set A to 1 if the line is still inside screen region
    ; or to 0 if there are no more lines, in which case
    ; SCREEN_PTR is invalid

    lda SCREEN_PTR_LO
    clc
    adc #SCREEN_LINE_SIZE_B
    sta SCREEN_PTR_LO
    bcc screen_ptr_next_line_no_inc_hi

    inc SCREEN_PTR_HI

screen_ptr_next_line_no_inc_hi:
    jsr screen_ptr_valid
    rts


clear_screen:
    ; args: X = zero-page address to number of bytes to clear

    jsr screen_ptr_reset
    
    lda #0

    ; while (screen_ptr_valid(screen_ptr)) {
clear_screen_row_loop:
    jsr screen_ptr_valid
    cmp #1
    bne clear_screen_end

    lda #0
    ldy #SCREEN_LINE_SIZE_B
    ;     while (y-- > 0) {
clear_screen_col_loop:
    ;         *screen_ptr[y] = A;
    dey
    sta (SCREEN_PTR_LO),Y
    ;    }
    bne clear_screen_col_loop

    ;    screen_ptr += line_size;
    jsr screen_ptr_next_line
    jmp clear_screen_row_loop
    ; }
clear_screen_end:
    rts


enter_standard_bitmap_mode:
    ; https://www.c64-wiki.com/wiki/Standard_Bitmap_Mode
    lda CONTROL_REG_1
    and #%10111111 ; clear bit 6
    ora #%00100000 ; set bit 5
    sta CONTROL_REG_1

    lda CONTROL_REG_2
    and #%11011111 ; clear bit 5
    sta CONTROL_REG_2

    rts


abs:
    cmp #0
    bpl abs_ret

    eor #$ff ; poor man's ~x
    clc
    adc #1

abs_ret:
    rts


draw_vertical_line:
    ; args: Y = X coordinate * 8
    jsr screen_ptr_reset

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
