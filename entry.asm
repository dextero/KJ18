    processor 6502
    org $0810

    include "core/memory.asm"

; =======================
; /consts/ ===============

MUSIC_LOAD_ADDR = $1000
MUSIC_PLAY_ADDR = $1003

TEXT_COLOR = 0
TEXT_BGCOLOR = 15

CONTROL_REG_1 = $d011
CONTROL_REG_2 = $d016
RASTER_COUNTER = $d012

PORT_A = $dc00
PORT_B = $dc01

JOYSTICK_ADDR  = $DC00

COLOR_MODE_RASTER = 220

SPRITE_ADDRESS = $0e80
GEAR_SPRITE_DATA = SPRITE_ADDRESS / $40
GEAR_LEVER_CENTER_X = $D5
GEAR_LEVER_CENTER_Y = $DC

GEAR_OFFSET = 16

GEAR_CHANGE_LEEWAY = 5

SCREEN_SKY_LINES = 6
SCREEN_STATUS_LINES = 4
SCREEN_LINE_SIZE_B = 320/8
SCREEN_NUM_LINES = 200/8-SCREEN_SKY_LINES-SCREEN_STATUS_LINES
SCREEN = $400+SCREEN_SKY_LINES*SCREEN_LINE_SIZE_B
SCREEN_SIZE = SCREEN_NUM_LINES * SCREEN_LINE_SIZE_B
SCREEN_END = SCREEN + SCREEN_SIZE

; BITMAP MUST be <=$3C00, and multiple of $400!
BITMAP = $2000
BITMAP_END = $4000
BITMAP_SIZE = BITMAP_END-BITMAP


; see draw_tracks
TRACK_UPPER_X = 18
TRACK_UPPER_WIDTH = 1
LINE_SKEW = 2

; =======================
; /variables/ ===========

CURRENT_SHIFTER_POS = 2050

JOYSTICK_STATE = 2048
SPACE_STATE = 2049

GEAR_LEVER_X = $d000
GEAR_LEVER_Y = $d001

SCREEN_PTR_LO = $2B
SCREEN_PTR_HI = $2C
SCREEN_LINE_ITERATOR = $2D
SCREEN_LINE_SKEW = $2E

MEMSET_ADDR_LO = $2F
MEMSET_ADDR_HI = $30
MEMSET_SIZE_LO = $31
MEMSET_SIZE_HI = $32

SCREEN_HLINE_OFFSET = $33
SCREEN_HLINE_STRIDE = 8

CURRENT_SPEED = $35 ; unsigned, 0 - full stop, 255 - max
SPEED_COUNTER = $36 ; slow speeds cause update every N-th frame

TIMER_START_JIFFIES_LO = $37
TIMER_START_JIFFIES_HI = $39

TIMER_ELAPSED_JIFFIES_LO = $3a
TIMER_ELAPSED_JIFFIES_HI = $3c

SCREEN_LINE_COLOR = $3d

FINISH_LINE_POS_LO = $0000
FINISH_LINE_POS_HI = $0003

; reuse memory - these are never used while SCREEN_LINE_* vars are
SCREEN_HLINE_ROW = SCREEN_LINE_SKEW

NUMERATOR = $FD
DENUMERATOR = $FC
QUOTIENT = NUMERATOR

SKY_COLOR = 03
FIRST_COLOR = 05
TRACK_COLOR = $ff
BORDER_COLOR = 15

; =======================
; /init/ ================



    ;speed
    lda #0
    sta CURRENT_SPEED
    sta SPACE_STATE

    ;shifter
    lda #$04 
    sta CURRENT_SHIFTER_POS 

    ;sprite

    lda #TRACK_COLOR
    sta SCREEN_LINE_COLOR

    jsr reset_distance_traveled

; =======================
; /methods/   ===========

main: 

    jsr creators_screen
    jsr title_screen

    jsr split_screen
    jsr play_music

    jsr init_sprite

    jsr clear_screen
    jsr clear_sky
    jsr draw_tracks
    jsr timer_reset

    lda #BORDER_COLOR
    sta $d020

loop:
    ;handle movement
    jsr read_space
    lda SPACE_STATE
    beq rest 
    jsr update_gearbox
rest:

    jsr calculate_speed
    jsr update_distance_traveled

    jsr sync_screen
    jsr update_tracks
    jsr draw_speed
    
    jsr is_finish_line_reached
    cmp #1

    bne loop

    jsr clear_sprites

    jsr disable_interrupts
    jsr timer_get_elapsed
    jsr highscore_screen

    jmp main

; =======================
; /includes/ ============
    include "core/split_screen.asm"
    include "core/init_interupts.asm"
    include "core/multicolor_mode.asm"
    include "core/text_mode.asm"
    include "core/title_screen.asm"
    include "core/creators_screen.asm"
    include "core/set_bank_one.asm"
    include "core/set_bank_two.asm"
    include "core/read_space.asm"
    include "core/play_music.asm"
    include "core/draw.asm"
    include "core/math.asm"
    include "core/calculate_speed.asm"
    include "core/update_gearbox.asm"
    include "core/draw_speed.asm"
    include "core/timer.asm"
    include "core/wait_for_space.asm"
    include "core/highscore_screen.asm"
    include "core/update_distance_traveled.asm"
    include "core/sprite.asm"

; =======================
; /data/ ================
            
    org SPRITE_ADDRESS 
    incbin "content/sprite_2.spr"

    org SPRITE_ADDRESS + $40
    incbin "content/gearbox.spr"

    org $1000-$7e
    INCBIN "content/music.sid"

    org BITMAP
    ; set bitmap to 01010101 pattern
    ; this way it is overridden with SCREEN
    ; 00 - draw BITMAP
    ; 01 - draw SCREEN (color = high nibble of SCREEN pixel)
    ; 10 - draw SCREEN (color = low nibble of SCREEN pixel)
    ; 11 - draw SCREEN (get color from COLOR_RAM[pixel])
    ds BITMAP_SIZE,$aa

    org    $5FFE
    incbin "content/creators_screen.prg"

   
speed_msg .byte "SPEED: ";
speed_msg_size = . - speed_msg
gear_msg .byte " G: ";
gear_msg_size = . - gear_msg
spaces .byte "     "
spaces_size = . - spaces

title_msg	.byte "maly penis farme mial, ia, ia ou"
title_msg_size = . - title_msg

highscore_msg	.byte "stuff delivered"
highscore_msg_size = . - highscore_msg

your_score_msg_1 .byte "yOU TRAINSMITTED SOME STUFF IN"
your_score_msg_1_size = . - your_score_msg_1

your_score_msg_2 .byte "ARBITRARY UNITS OF TIME"
your_score_msg_2_size = . - your_score_msg_2
