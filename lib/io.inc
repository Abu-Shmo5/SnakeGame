; Static Input
; rdi = db address
; Output
; rax = db address len
strlen:
    push  rdi
    push  rcx
    sub   rcx, rcx
    mov   rcx, -1
    sub   al, al
    cld
    repne scasb
    neg   rcx
    sub   rcx, 1
    mov   rax, rcx
    pop   rcx
    pop   rdi
    ret


; Static Input
; rdi = db address
; Output
; stdout = db address
print:
    call  strlen
    mov   rdx, rax
    mov   rsi, rdi
    mov   rdi, 1
    mov   rax, 1
    syscall
    ret