;==test=============================
    processor   6502
    org	$1000

    jsr draw_text
loop:        
    jmp loop
;===================================
    
draw_text:
    jsr $e544 ; clear screen

    lda #$16  ; setup font position
    sta $d018

    ldx #$00
write:      
    lda    msg,x
    jsr    $ffd2
    inx
    cpx    #54
    bne    write

    ldx #$00

setcolor:  
    lda #$07
    sta $d800,x
    inx
    cpx #$54
    bne setcolor

    rts

msg	.byte "PENIS DO KURWY NEDZY"        
