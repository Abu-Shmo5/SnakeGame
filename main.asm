format ELF64 executable 3

segment readable executable

entry main

include 'lib/io.inc'
include 'lib/misc.inc'
include 'lib/convert.inc'

main:
    call draw_map

    lea rdi, [newline]
    call putc

    set_cursor 20, 20, x_pos, y_pos, player_pos

    lea rdi, [player_pos]
    call print

    lea rdi, [player]
    call putc

    lea rdi, [end_pos]
    call print

    lea rdi, [newline]
    call putc

    exit 0

draw_map:
    ; Loop 1 Wall 10
    mov rcx, 62
_top:
    lea rdi, [wall]
    call putc
    loop _top

    lea rdi, [newline]
    call putc 


    mov r8, 30
    ; Loop 8 Wall 1 Space 8 Wall 1
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

    ; Loop 1 Wall 10
    mov rcx, 62
_bottom:
    lea rdi, [wall]
    call putc
    loop _bottom
    ret

segment readable writable

msg  db 'Hello world!', 10, 0
wall db '#'
player db '+'
newline db 10
space db 32
end_pos db 27, '[40;0H', 0
x_pos db '00', 0
y_pos db '00', 0
; player_pos db '00000000', 0
player_pos db 27, '[00;00H', 0