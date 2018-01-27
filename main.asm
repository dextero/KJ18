    processor 6502
    org $1000

    include "core/memory.asm"

    mac clear_screen
    jsr $e544
    endm

BG_COLOR = $d021

CONTROL_REG_1 = $d011
CONTROL_REG_2 = $d016
MEMORY_POINTERS = $d018

RASTER_COUNTER = $d012

STACK = $100

SCREEN = $400
SCREEN_LO = $00
SCREEN_HI = $04

SCREEN_END_LO = $e8
SCREEN_END_HI = $07

SCREEN_PTR_LO = $2B
SCREEN_PTR_HI = $2C
SCREEN_LINE_ITERATOR = $2D
SCREEN_LINE_SKEW = $2E

; reuse memory
SCREEN_HLINE_STRIDE = SCREEN_LINE_ITERATOR
SCREEN_HLINE_ROW = SCREEN_LINE_SKEW

MEMSET_ADDR_LO = $2F
MEMSET_ADDR_HI = $30

SCREEN_HLINE_OFFSET = $31

SCREEN_LINE_SIZE_B = 320/8
SCREEN_NUM_LINES = 200/8

; BITMAP MUST be <=$3C00, and multiple of $400!
BITMAP = $2000
BITMAP_END = $4000
BITMAP_SIZE = BITMAP_END-BITMAP

TRACK_UPPER_X = 18
TRACK_UPPER_WIDTH = 4
LINE_SKEW = 3

NUMERATOR = $FD
DENUMERATOR = $FC
QUOTIENT = NUMERATOR

main:
    jsr enter_multicolor_bitmap_mode

    lda #0
    sta SCREEN_HLINE_OFFSET

loop:
    clear_screen

    ldy #TRACK_UPPER_X
    ldx #-LINE_SKEW
    jsr draw_diagonal_line

    ldy #TRACK_UPPER_X+TRACK_UPPER_WIDTH
    ldx #LINE_SKEW
    jsr draw_diagonal_line

    lda SCREEN_HLINE_OFFSET
    ; (*) slow down a bit (update each 2 frames)
    lsr

    sta SCREEN_HLINE_ROW
    lda #LINE_SKEW+1
    sta SCREEN_HLINE_STRIDE
    jsr draw_horizontal_lines

    ; offset = (offset + 1) % LINE_SKEW
    inc SCREEN_HLINE_OFFSET
    lda #LINE_SKEW*2 ; TODO: 2 because (*)
    cmp SCREEN_HLINE_OFFSET
    bne loop_no_reset

    lda #0
    sta SCREEN_HLINE_OFFSET

loop_no_reset:
    jsr sync_screen
    jmp loop


sync_screen:
    lda RASTER_COUNTER
    cmp #$00
    bne sync_screen
    rts


draw_horizontal_line:
    ; Y - row
    ; X - col
    ; A - width

    pha
    jsr screen_ptr_reset

.draw_horizontal_line_skip_row:
    dey
    beq .draw_horizontal_line_draw
    jsr screen_ptr_next_line
    cmp #1
    bne .draw_horizontal_line_ret ; invalid row
    jmp .draw_horizontal_line_skip_row

.draw_horizontal_line_draw:
    txa
    adc SCREEN_PTR_LO
    sta MEMSET_ADDR_LO
    lda #0
    adc SCREEN_PTR_HI
    sta MEMSET_ADDR_HI

    pla
    tay
    lda #$ff
    jsr memset
    rts

.draw_horizontal_line_ret:
    pla
    rts


; normal binary division
; NUMERATOR = NUMERATOR / DENUMERATOR
; A = NUMERATOR % DENUMERATOR
; http://6502org.wikidot.com/software-math-intdiv
divide:
    LDA #0
    LDX #8
    ASL NUMERATOR
L1:
    ROL
    CMP DENUMERATOR
    BCC L2
    SBC DENUMERATOR
L2:
    ROL NUMERATOR
    DEX
    BNE L1

    rts


draw_horizontal_lines:
    ; SCREEN_HLINE_STRIDE - stride
    ; SCREEN_HLINE_ROW - first row to draw

    ; while (SCREEN_HLINE_ROW < SCREEN_NUM_LINES) {
.draw_horizontal_lines_next
    ; X = TRACK_UPPER_X - SCREEN_HLINE_ROW / LINE_SKEW
    lda SCREEN_HLINE_ROW
    sta NUMERATOR
    lda #LINE_SKEW
    sta DENUMERATOR
    jsr divide
    lda #TRACK_UPPER_X

    ; if carry clear, sbc subtracts extra 1
    ; we actually want this extra -1 here
    clc ; fucking sbc how does it work
    sbc QUOTIENT
    tax

    ; A = TRACK_UPPER_WIDTH + 2 * (Y / LINE_SKEW)
    ; dunno lol @ -1
    lda #TRACK_UPPER_WIDTH-1
    clc
    adc QUOTIENT ; this should never overflow
    adc QUOTIENT

    ldy SCREEN_HLINE_ROW
    jsr draw_horizontal_line

    ;     SCREEN_HLINE_ROW += SCREEN_HLINE_STRIDE
    lda SCREEN_HLINE_ROW
    clc
    adc SCREEN_HLINE_STRIDE
    sta SCREEN_HLINE_ROW
    ; }
    cmp #SCREEN_NUM_LINES
    bcc .draw_horizontal_lines_next

.draw_horizontal_lines_ret:
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


enter_multicolor_bitmap_mode:
    ; RST8 ECM BMM DEN RSEL YSCROLL
    ;   0   0   1   1    1    011
    lda #%00111011 ; == $3b
    sta CONTROL_REG_1

    ; - - RES MCM CSEL XSCROLL
    ; 0 0  0   1   1     000
    lda #%00011000 ; == $18
    sta CONTROL_REG_2

    ; setup bitmap offset
    lda #$10|BITMAP/$400
    sta MEMORY_POINTERS

    rts


abs:
    cmp #0
    bpl abs_ret

    eor #$ff ; poor man's ~x
    clc
    adc #1

abs_ret:
    rts


draw_diagonal_line:
    ; args: Y = X coordinate * 8 [unsigned]
    ;       X = skew [signed]; 0 = vertical; -X /; +x \

    jsr screen_ptr_reset

    stx SCREEN_LINE_SKEW

    ; x = abs(x)
    ; original signed skew in SCREEN_LINE_SKEW
    txa
    jsr abs
    tax
    sta SCREEN_LINE_ITERATOR ; skew counter

    ; while (screen_ptr_valid(screen_ptr)) {
draw_diagonal_line_loop:
    jsr screen_ptr_valid
    cmp #1
    bne draw_diagonal_line_end

    dec SCREEN_LINE_ITERATOR
    bne draw_diagonal_line_loop_no_skew

    ; skew by 1
    lda #0
    cmp SCREEN_LINE_SKEW
    beq draw_diagonal_line_loop_no_skew
    bpl draw_diagonal_line_loop_skew_left

    ; skew right, reset skew counter
    iny
    stx SCREEN_LINE_ITERATOR
    jmp draw_diagonal_line_loop_no_skew

draw_diagonal_line_loop_skew_left:
    ; skew left, reset skew counter
    dey
    stx SCREEN_LINE_ITERATOR
    jmp draw_diagonal_line_loop_no_skew

draw_diagonal_line_loop_no_skew:
    lda #$ff
    sta (SCREEN_PTR_LO),Y

    ;    screen_ptr += line_size;
    jsr screen_ptr_next_line
    jmp draw_diagonal_line_loop
    ; }
draw_diagonal_line_end:
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


memset subroutine
    ; fill .size bytes starting from MEMSET_ADDR with .value
    ; A - value
    ; Y - size

.memset_loop:
    sta (MEMSET_ADDR_LO),y
    dey
    bne .memset_loop

    rts



    org BITMAP
    ; set bitmap to 01010101 pattern
    ; this way it is overridden with SCREEN
    ; 00 - draw BITMAP
    ; 01 - draw SCREEN (color = high nibble of SCREEN pixel)
    ; 10 - draw SCREEN (color = low nibble of SCREEN pixel)
    ; 11 - draw SCREEN (get color from COLOR_RAM[pixel])
    ds BITMAP_SIZE,$aa
