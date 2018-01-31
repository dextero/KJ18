; arguments - KEY_ constant (see above)
; outputs: Z set if key down, clear if up
    mac is_key_down

.a SET ~(1 << (({1} >> 3) & %000111))
.b SET  (1 << (({1} >> 0) & %000111))

    ldx #.a
    ldy #.b
    jsr is_key_down_impl

    endm
