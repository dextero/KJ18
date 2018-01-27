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