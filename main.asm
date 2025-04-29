format ELF64 executable 3

segment readable executable

entry main

include 'lib/io.inc'
include 'lib/misc.inc'
include 'lib/convert.inc'

; TODO: Colouring
; TODO: Keyboard interrupt end game

main:
    call termios_save_and_disable_echo
    mov rax, 13
    mov rdi, 2
    lea rsi, [sigact]
    mov r10, 8
    xor rdx, rdx
    syscall

    call draw_map

    lea rdi, [newline]
    call putc


update:
    set_cursor x, y, x_pos, y_pos, player_pos

    lea rdi, [player_pos]
    call print

    lea rdi, [player]
    call putc
    
    mov rax, 35
    mov rdi, sleeptime
    xor rsi, rsi
    syscall

    call check_wall
    cmp rax, 1
    je gameover
    
    lea rdi, [player_pos]
    call print

    lea rdi, [space]
    call putc
    
    call move_pos
    jmp update

    lea rdi, [end_pos]
    call print

    lea rdi, [newline]
    call putc
game_end:
    call termios_restore
    exit 0

gameover:
    lea rdi, [end_pos]
    call print

    lea rdi, [gameover_message]
    call print
    jmp game_end

move_pos:
    cmp [move_side], 1
    je .move_up
    cmp [move_side], 2
    je .move_right
    cmp [move_side], 3
    je .move_left
    cmp [move_side], 4
    je .move_bottom

.move_up:
    mov dl, [y]
    dec dl
    mov [y], dl
    jmp .ret
.move_right:
    mov dl, [x]
    inc dl
    mov [x], dl
    jmp .ret
.move_left:
    mov dl, [x]
    dec dl
    mov [x], dl
    jmp .ret
.move_bottom:
    mov dl, [y]
    inc dl
    mov [y], dl
.ret:
    ret

check_wall:
    cmp [move_side], 1
    je .check_top_wall
    cmp [move_side], 2
    je .check_right_wall
    cmp [move_side], 3
    je .check_left_wall
    cmp [move_side], 4
    je .check_bottom_wall
    jmp .ret


.check_top_wall:
    mov al, [y]
    dec al
    cmp al, [up_wall_y]
    jg .ret
    mov rax, 1
    jmp .ret

.check_right_wall:
    mov al, [x]
    inc al
    cmp al, [right_wall_x]
    jb .ret
    mov rax, 1
    jmp .ret

.check_left_wall:
    mov al, [x]
    dec al
    cmp al, [left_wall_x]
    jg .ret
    mov rax, 1
    jmp .ret

.check_bottom_wall:
    mov al, [y]
    inc al
    cmp al, [down_wall_y]
    jb .ret
    mov rax, 1

.ret:
    ret

draw_map:
    mov rcx, 62
.top:
    lea rdi, [wall]
    call putc
    loop .top

    lea rdi, [newline]
    call putc 


    mov r8, 30
.center:
    lea rdi, [wall]
    call putc 

    mov r9, 60
.spaces:
    lea rdi, [space]
    call putc 
    dec r9
    cmp r9, 0
    jnz .spaces

    lea rdi, [wall]
    call putc

    lea rdi, [newline]
    call putc 

    dec r8
    cmp r8, 0
    jnz .center

    mov rcx, 62
.bottom:
    lea rdi, [wall]
    call putc
    loop .bottom
    ret

ctrl_c_handler:
    lea rdi, [end_pos]
    call print

    lea rdi, [exiting_game_message]
    call print

    jmp game_end

restorer:
    mov rax, 15
    syscall
termios_save_and_disable_echo:
        ; TCGETS -> oldios
        mov     rax, 16
        xor     rdi,rdi
        mov     rsi,0x5401
        lea     rdx,[oldios]
        syscall
        ; copy oldios → newios
        mov     rcx,60/8
        lea     rsi,[oldios]
        lea     rdi,[newios]
.rep:   lodsq
        stosq
        loop    .rep
        ; clear ECHO & ICANON
        and     dword [newios+0x0c], not (0000010o or 0000002o)
        ; TCSETS newios
        mov     rax, 16
        xor     rdi,rdi
        mov     rsi,0x5402
        lea     rdx,[newios]
        syscall
        ret

termios_restore:
        mov     rax,16
        xor     rdi,rdi
        mov     rsi,0x5402
        lea     rdx,[oldios]
        syscall
        ret


segment readable writable

gameover_message db 'Gameover!!', 10, 0
exiting_game_message db 'End game, Bye!!', 10, 0
wall db '#'
player db '+'
newline db 10
space db 32
end_pos db 27, '[40;0H', 0
x db 20
y db 20
x_pos db '00', 0
y_pos db '00', 0
; player_pos db '00000000', 0
player_pos db 27, '[00;00H', 0
sleeptime dq 0, 500000000
left_wall_x db 1
right_wall_x db 62
up_wall_y db 3
down_wall_y db 34
; move_side 1 == top
; move_side 2 == right
; move_side 3 == left
; move_side 4 == bottom
move_side db 4
oldios      rb  60
newios      rb  60
sigact dq ctrl_c_handler, 0x04000000, restorer, 0