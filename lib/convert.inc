; Input
; rdi = db address
; ax = code value
; Output
; rdi = str in db address
eight_bit_to_str:
    push cx
    xor cx, cx
    mov cl, 10
    DIV cl
    add al, 48
    add ah, 48
    mov [rdi+1], ah
    mov [rdi], al
    pop cx
    ret