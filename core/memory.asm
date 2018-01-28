;//////////////////////////////////////////////////////////
;// COPY_MEMORY {from_addr, to_addr, byte_size}
;// - copies bytes from specified address to another
;//////////////////////////////////////////////////////////

    mac	copy_memory

.from SET {1}
.to SET {2}
.size SET {3}

     ldx #.size
cpyspr:
    lda .from,x
    sta .to,x
    dex
    cpx #-1
    bne cpyspr
    rts

    endm


    mac add16_imm
.mem SET {1}
.imm SET {2}

    pha
    lda .mem
    clc
    adc #<.imm
    sta .mem
    lda .mem+1
    adc #>.imm
    sta .mem+1
    pla

    endm


    mac sub16_imm
.mem SET {1}
.imm SET {2}

    pha
    lda .mem+1
    sec
    sbc #>.imm
    sta .mem+1
    lda .mem
    sbc #<.imm
    sta .mem
    pla

    endm


    mac write
.text SET {1}
.size SET {2}

    ldx #$00
.write:
    lda .text,x
    jsr $ffd2
    inx
    cpx #.size
    bne .write

    endm


    mac move_cursor
.x SET {1}
.y SET {2}

    clc
    ldx #.y ; yup
    ldy #.x
    jsr $fff0
    endm


    mac text_color
.col SET {1}
    lda #.col
    sta $0286
    endm


    mac text_bgcolor
.col SET {1}
    lda #.col
    sta $d021
    endm
