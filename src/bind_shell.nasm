global _start

section .text

_start:
	mov rbp, rsp ; Set stack base
	jmp _data

_main:
	pop r15 ; Keep reference to strings

; Build a server sockaddr_struct on the stack
	xor rax, rax
	add ax, 2
	shl rax, 16
	add ax, 23569
	shl rax, 32
	push rax
	
; Create Socket
	xor rax, rax
	mov rdx, rax	
	inc rax
	mov rsi, rax	; SOCK_STREAM (1)
	inc rax
	mov rdi, rax	; AF_INET (2)
	add rax, 39	; SysCall 41
	syscall
	cmp rax, -1
	je _exit
	push rax ; Store socket id on stack
	
; Bind the Socket
	xor rax, rax
	add rax, 49
	mov rdi, [rbp-16] ; svr_sock id
	mov rsi, rbp	; sockaddr_in struct
	mov rdx, 16	; sockaddr_in size
	syscall
	cmp rax, -1
	je _exit

; Listen
	xor rax, rax
	add rax, 2
	mov rsi, rax
	add rax, 48
	syscall
	cmp rax, -1
	je _exit
	nop

_exit:
	mov rax, 0x3c
	mov rbx, 1
	syscall	
	nop
_data:
	call _main
	prompt: db "Speak friend and enter: "
	pass:	db "password", 0xa
	good:	db "Welcome", 0xa
	bad:	db "Wrong", 0xa
	



