;=========================
; /entry/ ================

split_screen:

	jsr init_interupts
	jsr text_mode
	jsr draw_speed

	rts

;=========================
; /subroutines/ ==========

begin_raster:
	jsr multicolor_mode

    jsr draw_tracks
	
	; chaining
	lda #<last_raster
	ldx #>last_raster
	sta $0314
	stx $0315

	ldy #COLOR_MODE_RASTER
	sty $d012

	asl $d019
	jmp	$ea81

last_raster:
	jsr text_mode


	; chaining
	lda #<begin_raster
	ldx #>begin_raster
	sta $0314
	stx $0315

	ldy #00
	sty $d012

	asl $d019
	jmp $ea81

draw_speed:
	clc
	ldx #240
	ldy #25
	jsr $fff0

	ldx #$00
write:      
	lda    speed_msg,x
	jsr    $ffd2
	inx
	cpx    #7
	bne    write

	ldx #$00

	; draw number
	LDA #$00
	LDX CURRENT_SPEED
	JSR $BDCD

	rts
