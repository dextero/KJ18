set_bank_one:

    lda $DD00
    and #%11111100
    ora #%00000011 ; second
    sta $DD00
    rts