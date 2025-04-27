format ELF64 executable 3

segment readable executable

entry main

include 'lib/io.inc'
include 'lib/misc.inc'
include 'lib/convert.inc'

; TODO: Colouring
; TODO: Keyboard interrupt end game

main:
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
    je _gameover
    
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
_end:
    exit 0

_gameover:
    lea rdi, [end_pos]
    call print

    lea rdi, [gameover_message]
    call print
    jmp _end

move_pos:
    cmp [move_side], 1
    je _move_up
    cmp [move_side], 2
    je _move_right
    cmp [move_side], 3
    je _move_left
    cmp [move_side], 4
    je _move_bottom

_move_up:
    mov dl, [y]
    dec dl
    mov [y], dl
    jmp _ret
_move_right:
    mov dl, [x]
    inc dl
    mov [x], dl
    jmp _ret
_move_left:
    mov dl, [x]
    dec dl
    mov [x], dl
    jmp _ret
_move_bottom:
    mov dl, [y]
    inc dl
    mov [y], dl
_ret:
    ret

check_wall:
    cmp [move_side], 1
    je _check_top_wall
    cmp [move_side], 2
    je _check_right_wall
    cmp [move_side], 3
    je _check_left_wall
    cmp [move_side], 4
    je _check_bottom_wall
    jmp _back


_check_top_wall:
    mov al, [y]
    dec al
    cmp al, [up_wall_y]
    jg _back
    mov rax, 1
    jmp _back

_check_right_wall:
    mov al, [x]
    inc al
    cmp al, [right_wall_x]
    jb _back
    mov rax, 1
    jmp _back

_check_left_wall:
    mov al, [x]
    dec al
    cmp al, [left_wall_x]
    jg _back
    mov rax, 1
    jmp _back

_check_bottom_wall:
    mov al, [y]
    inc al
    cmp al, [down_wall_y]
    jb _back
    mov rax, 1

_back:
    ret

draw_map:
    mov rcx, 62
_top:
    lea rdi, [wall]
    call putc
    loop _top

    lea rdi, [newline]
    call putc 


    mov r8, 30
_center:
    lea rdi, [wall]
    call putc 

    mov r9, 60
_spaces:
    lea rdi, [space]
    call putc 
    dec r9
    cmp r9, 0
    jnz _spaces

    lea rdi, [wall]
    call putc

    lea rdi, [newline]
    call putc 

    dec r8
    cmp r8, 0
    jnz _center

    mov rcx, 62
_bottom:
    lea rdi, [wall]
    call putc
    loop _bottom
    ret

segment readable writable

gameover_message  db 'Gameover!!', 10, 0
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
