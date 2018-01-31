; arguments - KEY_ constant (see above)
; outputs: Z set if key down, clear if up
    mac wait_for_key

.a SET ~(1 << (({1} >> 3) & %000111))
.b SET  (1 << (({1} >> 0) & %000111))

    ldx #.a
    ldy #.b
    jsr wait_for_key_impl

    endm
