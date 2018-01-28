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

SPRITE_ADDRESS = $0e00
GEAR_SPRITE_DATA = SPRITE_ADDRESS / $40
GEAR_LEVER_CENTER_X = $D5
GEAR_LEVER_CENTER_Y = $DC

GEAR_OFFSET = 16

GEAR_CHANGE_LEEWAY = 5
; gain speed slightly faster than slowing down
SPEEDUP_FACTOR = 2
SLOWDOWN_FACTOR = 3

SCREEN_SKY_LINES = 6
SCREEN_STATUS_LINES = 4
SCREEN_LINE_SIZE_PIX = 320
SCREEN_LINE_SIZE_B = SCREEN_LINE_SIZE_PIX/8
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

SPRITE_MASK = $d015
SPRITE_DOUBLE_WIDTH = $d01d
SPRITE_DOUBLE_HEIGHT = $d017

SPRITE_COW_BIT = %00000100

SPRITE_2_X = $d002
SPRITE_2_Y = $d003

SPRITE_3_X = $d004
SPRITE_3_Y = $d005

SPRITE_TREE_X = $d00a
SPRITE_TREE_Y = $d00b

; =======================
; /variables/ ===========

TREE_UNDERFLOW = 2060

JOYSTICK_STATE = 2048
SPACE_STATE = 2049
CURRENT_SHIFTER_POS = 2050
TITLE_SELECTED = 2051
JOYSTICK_FIRE = 2052

COW_UNDERFLOW = 2053
COW_VISIBLE = 2054
LETHAL_SPEED = 100
COW_SPRITE_SIZE = 32
COW_START_X = 0
COW_START_Y = 80


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

TIMER_LO = $37
TIMER_HI = $38

TIMER_START_JIFFIES_LO = $39
TIMER_START_JIFFIES_HI = $3a

TIMER_ELAPSED_JIFFIES_LO = $3b
TIMER_ELAPSED_JIFFIES_HI = $3c

SCREEN_LINE_COLOR = $3d

FINISH_LINE_POS_LO = $0000
FINISH_LINE_POS_HI = $0008

; reuse memory - these are never used while SCREEN_LINE_* vars are
SCREEN_HLINE_ROW = SCREEN_LINE_SKEW

NUMERATOR = $FD
DENUMERATOR = $FC
QUOTIENT = NUMERATOR

SKY_COLOR = 03
FIRST_COLOR = 05
TRACK_COLOR = $ff
BORDER_COLOR = 11

; =======================
; /init/ ================

init:
    ;speed
    lda #0
    sta CURRENT_SPEED
    sta SPACE_STATE
    sta TITLE_SELECTED
	sta TREE_UNDERFLOW

    ;shifter
    lda #$04 
    sta CURRENT_SHIFTER_POS 

    ;sprite

    lda #TRACK_COLOR
    sta SCREEN_LINE_COLOR

; =======================
; /methods/   ===========

main: 

    jsr creators_screen
    jsr title_screen

    jsr split_screen
    jsr play_music

    jsr init_sprite

    jsr reset_distance_traveled
    jsr reset_cow

    jsr clear_screen
    jsr clear_sky
    jsr draw_tracks
    jsr timer_reset

    lda #BORDER_COLOR
    sta $d020

loop:
    ;handle movement
    jsr read_fire
    lda JOYSTICK_FIRE
    beq rest 
    jsr update_gearbox
rest:

    jsr calculate_speed
    jsr update_distance_traveled

    jsr sync_screen
    jsr update_tracks
    jsr update_cow
	jsr update_tree
    jsr draw_speed
    
    jsr is_finish_line_reached
    cmp #1

    bne loop

    jsr clear_sprites

    jsr disable_interrupts
    jsr timer_get_elapsed
    jsr highscore_screen

    jmp init

; =======================
; /data/ ================
            
    org SPRITE_ADDRESS 
    incbin "content/gearlever.spr"

    org SPRITE_ADDRESS + $40
    incbin "content/gearbox.spr"

    org SPRITE_ADDRESS + $80
    incbin "content/cow.spr"

    org SPRITE_ADDRESS + $C0
    incbin "content/train.spr"

    org SPRITE_ADDRESS + $100
    incbin "content/gearbcg.spr"

    org SPRITE_ADDRESS + $140
    incbin "content/tree.spr"

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
    include "core/update_cow.asm"
    include "core/read_fire.asm"
    include "core/update_tree.asm"

speed_msg .byte "SPEED: ";
speed_msg_size = . - speed_msg
rpm_msg .byte "RPM: ";
rpm_msg_size = . - rpm_msg
rpm_suffix .byte "00"
rpm_suffix_size = . - rpm_suffix

spaces .byte "     "
spaces_size = . - spaces

highscore_msg	.byte "stuff delivered"
highscore_msg_size = . - highscore_msg

your_score_msg_1 .byte "yOU TRAINSMITTED SOME STUFF IN"
your_score_msg_1_size = . - your_score_msg_1

your_score_msg_2 .byte "ARBITRARY UNITS OF TIME"
your_score_msg_2_size = . - your_score_msg_2

selection_msg .byte " << ===="
selection_msg_size = . - selection_msg 

title_screen_msg .byte "                                        "
                 .byte "            ==trainsmission==           "
                 .byte "                                        "
                 .byte "     -gear up!                          "
                 .byte "     -gear down!                        "
                 .byte "     -faster than small town!           "
                 .byte "                                        "
                 .byte "                                        "
                 .byte "                                        "
                 .byte "                                        "
                 .byte "                                        "
                 .byte "                                        "
                 .byte "                                        "
                 .byte "                                        "
                 .byte "                                        "
                 .byte "	                   MUSIC BY bzyk @ 1997   "
                 .byte " CODE & ART BY dextero, mcpgnz @ 2017   "
                 .byte "                                        "
                 .byte "                                        "
              
