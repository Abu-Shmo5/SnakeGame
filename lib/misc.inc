macro exit code {
    mov rdi, code
    mov  rax, 60
    syscall
}

macro set_cursor row, column, column_address, row_address, pos {
    mov rdi, row_address
    mov ax, row
    call eight_bit_to_str 

    mov rdi, column_address
    mov ax, column
    call eight_bit_to_str 

    mov rdi, row_address
    mov cl, [rdi]
    lea r8, [pos]
    mov [r8+2], cl
    mov cl, [rdi+1]
    mov [r8+3], cl

    mov rdi, column_address
    mov cl, [rdi]
    lea r8, [pos]
    mov [r8+5], cl
    mov cl, [rdi+1]
    mov [r8+6], cl
}