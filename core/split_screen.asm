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

	; muzig
	jsr $1003

    inc TIMER_LO
    bne .timer_no_carry
    inc TIMER_HI
.timer_no_carry:

	; chaining
	lda #<begin_raster
	ldx #>begin_raster
	sta $0314
	stx $0315

	ldy #00
	sty $d012

	asl $d019
	jmp $ea81


