include "const.inc"

macro exit code {
    mov rdi, code
    mov  rax, SYS_exit
    syscall
}

macro set_cursor column, row, column_address, row_address, pos {
    xor ax, ax
    mov rdi, row_address
    mov al, [row]
    call eight_bit_to_str 

    xor ax, ax
    mov rdi, column_address
    mov al, [column]
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