set_bank_two:

    lda $DD00
    and #%11111100
    ora #%00000010 ; second
    sta $DD00

    rts
