format ELF64 executable 3

segment readable executable

entry main

include 'lib/io.inc'
include 'lib/misc.inc'

main:
    lea rdi, [msg]
    call print 

    syscall
    exit 0

segment readable writable

msg  db 'Hello world!', 10, 0