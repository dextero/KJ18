; in: A
; out: abs(A)
abs:
    cmp #0
    bpl abs_ret

    eor #$ff ; poor man's ~x
    clc
    adc #1

abs_ret:
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


; Executes an unsigned integer division of a 24-bit dividend by a 24-bit divisor
; the result goes to dividend and remainder variables
;
; Verz!!! 18-mar-2017
div24:
    lda #0	        ;preset remainder to 0
	sta div24_remainder
	sta div24_remainder+1
	sta div24_remainder+2
	ldx #24	        ;repeat for each bit: ...

.divloop:
    asl div24_dividend	;dividend lb & hb*2, msb -> Carry
	rol div24_dividend+1
	rol div24_dividend+2
	rol div24_remainder	;remainder lb & hb * 2 + msb from carry
	rol div24_remainder+1
	rol div24_remainder+2
	lda div24_remainder
	sec
	sbc div24_divisor	;substract divisor to see if it fits in
	tay	        ;lb result -> Y, for we may need it later
	lda div24_remainder+1
	sbc div24_divisor+1
	sta div24_pztemp
	lda div24_remainder+2
	sbc div24_divisor+2
	bcc .skip	;if carry=0 then divisor didn't fit in yet

	sta div24_remainder+2	;else save substraction result as new remainder,
	lda div24_pztemp
	sta div24_remainder+1
	sty div24_remainder
	inc div24_dividend 	;and INCrement result cause divisor fit in 1 times

.skip:
    dex
	bne .divloop
	rts

div24_dividend 	.ds 3
div24_divisor 	.ds 3
div24_remainder .db
div24_pztemp 	.db

; A*256 + X = mul8_a * mul8_b
mul8:
    lda #$00
    ldx #$08
    clc
.m0:
    bcc .m1
    clc
    adc mul8_b
.m1:
    ror
    ror mul8_a
    dex
    bpl .m0
    ldx mul8_a
    rts

mul8_a .db
mul8_b .db
