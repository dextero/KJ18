; waits until a key is pressed and released
; inputs: X - column
;         Y - row
;         See is_key_down_impl for details
; arguments: KEY_ constant
wait_for_key_impl subroutine

.wait_until_down:
    jsr is_key_down_impl
    bne .wait_until_down

.wait_until_up:
    jsr is_key_down_impl
    beq .wait_until_up

    rts
