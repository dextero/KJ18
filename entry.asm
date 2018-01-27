    processor 6502
    org $0810

    include "core/memory.asm"

; =======================
; /consts/ ===============

MUSIC_LOAD_ADDR = $1000
MUSIC_PLAY_ADDR = $1003

CONTROL_REG_1 = $d011
CONTROL_REG_2 = $d016
RASTER_COUNTER = $d012

PORT_A = $dc00
PORT_B = $dc01

JOYSTICK_ADDR  = $DC00

COLOR_MODE_RASTER = 220

GEAR_SPRITE_DATA = $80
GEAR_LEVER_CENTER_X = $25
GEAR_LEVER_CENTER_Y = $D6

GEAR_OFFSET = 16

SCREEN = $400
SCREEN_LINE_SIZE_B = 320/8
SCREEN_STATUS_LINES = 5
SCREEN_NUM_LINES = 200/8-SCREEN_STATUS_LINES
SCREEN_SIZE = SCREEN_NUM_LINES * SCREEN_LINE_SIZE_B
SCREEN_END = SCREEN + SCREEN_SIZE

; BITMAP MUST be <=$3C00, and multiple of $400!
BITMAP = $2000
BITMAP_END = $4000
BITMAP_SIZE = BITMAP_END-BITMAP


; see draw_tracks
TRACK_UPPER_X = 18
TRACK_UPPER_WIDTH = 4
LINE_SKEW = 3

; =======================
; /variables/ ===========

CURRENT_SPEED = 2051;
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

; reuse memory - these are never used while SCREEN_LINE_* vars are
SCREEN_HLINE_STRIDE = SCREEN_LINE_ITERATOR
SCREEN_HLINE_ROW = SCREEN_LINE_SKEW

NUMERATOR = $FD
DENUMERATOR = $FC
QUOTIENT = NUMERATOR

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
    lda #GEAR_LEVER_CENTER_X
    sta GEAR_LEVER_X

    lda #GEAR_LEVER_CENTER_Y
    sta GEAR_LEVER_Y


; =======================
; /methods/   ===========

main: 

    jsr creators_screen
    jsr split_screen
loop:
    

    jsr clear_screen
    jsr sync_screen
    jsr draw_tracks
    
    jmp loop
    rts

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

; =======================
; /data/ ================
            
    org $1000-$7e
    INCBIN "content/music.sid"

   ; org $2000
   ; incbin "content/gear_knob.spr"

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
title_msg	.byte "                                        "   
            .byte "                HEY!                    "   