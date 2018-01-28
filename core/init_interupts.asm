; defines <begin_raster> interupt

; =======================
; /entry/   =============

init_interupts:
	sei

	; disable timer, keyboard interupts
	lda #$7f
	sta $dc0d
	sta $dd0d

	; enable raster interupts
	lda #$01
	sta $d01a

	; load interuption pointer
	lda #<begin_raster
	ldx #>begin_raster
	sta $0314
	stx $0315

	ldy #$00
	sty $d012

	; clear pending interupts
	lda $dc0d
	lda $dd0d
	asl $d019

	cli
	rts

; https://digitalerr0r.wordpress.com/2011/05/01/commodore-64-programming-9-interrupts-and-music/

disable_interrupts:
    sei

    ;disable raster interrupts
    lda #$00
    sta $d01a

	; restore original interuption pointer
	lda #$31
	ldx #$ea
	sta $0314
	stx $0315

	; clear pending interupts
	lda $dc0d
	lda $dd0d
	asl $d019

    cli
    rts
