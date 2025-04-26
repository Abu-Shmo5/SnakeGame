macro exit code {
    mov rdi, code
    mov  rax, 60
    syscall
}