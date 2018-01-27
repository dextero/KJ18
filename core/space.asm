;//////////////////////////////////////////////////////////
;// reads space state and saves it in SPACE_STATE variable
;//////////////////////////////////////////////////////////

read_space:

PORT_A = $dc00
PORT_B = $dc01

    sei

    lda #%11111111  ; CIA#1 port A = outputs 
    sta $dc02       ; CIA#1 (Data Direction Register A)            

    lda #%00000000  ; CIA#1 port B = inputs
    sta $dc03       ; CIA#1 (Data Direction Register B)          
    
    ; operations
    lda #%01111111  ; column 
    sta PORT_A  

    ; clear space
    lda #$00
    sta SPACE_STATE 

    lda PORT_B 
    and #%00010000  ; row
    bne ret_read_space

    lda #$01
    sta SPACE_STATE

ret_read_space:
    cli
    rts