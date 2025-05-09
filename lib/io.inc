include "const.inc"
putc:
    push rcx
    mov rdx, 1
    mov rsi, rdi
    mov rdi, 1
    mov rax, SYS_write
    syscall
    pop rcx
    ret

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
    mov   rax, SYS_write
    syscall
    ret

; Static Input
; rdi = db address
readc:
    mov rax, SYS_read
    mov rsi, rdi
    mov rdi, 0
    mov rdx, 1
    syscall
    ret

; Static Input
; rdi = db address
keep_readc:
    ;  until 0
.keep_reading:
    mov rax, SYS_read
    mov rsi, rdi
    mov rdi, 0
    mov rdx, 1
    syscall

    cmp rax, 0
    jle .ret
    jmp .keep_reading


.ret:
    ret