format ELF64 executable 3

segment readable executable

entry main

include 'lib/io.inc'
include 'lib/misc.inc'
include 'lib/convert.inc'
include "lib/const.inc"

; TODO: Colouring (Apple txt Red; snake txt green; end game txt orange; gameover bg red)
; TODO: Clear screen (set cursor in correct unchanging pos)
; TODO: Pause
; TODO: Score
; TODO: Instructions
; TODO: Maps (Size/Walls)
; TODO: Challenges (Per Map / Daily) as in (Time restratin or score etc)
; TODO: Leaderboard


main:
    lea rdi, [clear_terminal]
    call print

    call termios_save_and_disable_echo_and_non_blocking
    mov rax, SYS_rt_sigaction
    mov rdi, 2
    lea rsi, [sigact]
    mov r10, 8
    xor rdx, rdx
    syscall

    call draw_map

    lea rdi, [newline]
    call putc


update:
    set_cursor int_player_position.x, int_player_position.y, x_pos, y_pos, player_pos

    lea rdi, [player_pos]
    call print

    lea rdi, [player]
    call putc
    
    mov rax, SYS_nanosleep
    mov rdi, sleeptime
    xor rsi, rsi
    syscall
    lea rdi, [inputc]
    call readc
    ; call keep_readc
    call update_move_side

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
    mov dl, [int_player_position.y]
    dec dl
    mov [int_player_position.y], dl
    jmp .ret
.move_right:
    mov dl, [int_player_position.x]
    inc dl
    mov [int_player_position.x], dl
    jmp .ret
.move_left:
    mov dl, [int_player_position.x]
    dec dl
    mov [int_player_position.x], dl
    jmp .ret
.move_bottom:
    mov dl, [int_player_position.y]
    inc dl
    mov [int_player_position.y], dl
.ret:
    ret
update_move_side:
    push ax
    push rbx
    push cx
    mov al, [inputc]
    ; cmp al, 'A'
    ; je .up
    ; cmp al, 'B'
    ; je .down
    ; cmp al, 'C'
    ; je .right
    ; cmp al, 'D'
    ; je .left
    ; jmp .ret

    mov rbx, move_side
    cmp al, 'w'
    je .up
    cmp al, 's'
    je .down
    cmp al, 'd'
    je .right
    cmp al, 'a'
    je .left
    jmp .ret
    
.up:
    mov cl, 1
    mov [rbx], cl
    jmp .ret
.down:
    mov cl, 4
    mov [rbx], cl
    jmp .ret
.right:
    mov cl, 2
    mov [rbx], cl
    jmp .ret
.left:
    mov cl, 3
    mov [rbx], cl
    jmp .ret

.ret:
    pop cx
    pop rbx
    pop ax
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
    mov al, [int_player_position.y]
    dec al
    cmp al, [int_wall_position.top]
    jg .ret
    mov rax, 1
    jmp .ret

.check_right_wall:
    mov al, [int_player_position.x]
    inc al
    cmp al, [int_wall_position.right]
    jb .ret
    mov rax, 1
    jmp .ret

.check_left_wall:
    mov al, [int_player_position.x]
    dec al
    cmp al, [int_wall_position.left]
    jg .ret
    mov rax, 1
    jmp .ret

.check_bottom_wall:
    mov al, [int_player_position.y]
    inc al
    cmp al, [int_wall_position.bottom]
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
    mov rax, SYS_rt_sigreturn
    syscall
termios_save_and_disable_echo_and_non_blocking:
        ; TCGETS -> oldios
        mov     rax, SYS_ioctl
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
        ; ; make reads return immediately
        mov     byte  [newios + 17 + 5], 0
        mov     byte  [newios + 17 + 6 ], 0

        ; --------  make stdin non-blocking  --------
        ; flags = fcntl(0, F_GETFL, 0)
        mov     eax, SYS_fcntl
        xor     edi, edi         ; fd = 0 (stdin)
        mov     esi, 3
        xor     edx, edx
        syscall                  ; eax = old flags

        ; fcntl(0, F_SETFL, flags | O_NONBLOCK)
        or      eax, 0x800
        mov     r9d, eax         ; save new flags
        mov     eax, SYS_fcntl
        xor     edi, edi
        mov     esi, 4
        mov     edx, r9d
        syscall
        
        ; TCSETS newios
        mov     rax, SYS_ioctl
        xor     rdi,rdi
        mov     rsi,0x5402
        lea     rdx,[newios]
        syscall
        ret

termios_restore:
        mov     rax, SYS_ioctl
        xor     rdi,rdi
        mov     rsi,0x5402
        lea     rdx,[oldios]
        syscall
        ret


segment readable writable

gameover_message db 'Gameover!!', 10, 0
exiting_game_message db 'End game, Bye!!', 10, 0
clear_terminal db 27,'[H', 27, '[2J', 0
wall db '#'
player db '+'
newline db 10
space db 32
end_pos db 27, '[40;0H', 0
int_player_position POINT 20, 20
x_pos db '00', 0
y_pos db '00', 0
; player_pos db '00000000', 0
player_pos db 27, '[00;00H', 0
; sleeptime dq 0, 62500000
sleeptime dq 0, 125000000
; sleeptime dq 0, 250000000
; sleeptime dq 0, 500000000
int_wall_position WALL_POINTS 1, 32, 1, 62
; move_side 1 == top
; move_side 2 == right
; move_side 3 == left
; move_side 4 == bottom
move_side db 4
oldios      rb  60
newios      rb  60
sigact dq ctrl_c_handler, 0x04000000, restorer, 0
inputc db 0