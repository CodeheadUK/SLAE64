global _start
section .text

_start:
	push 1
	pop rsi
	mov rax, 0x90909090
_test:
	cmp [rsi], rax
	je _found
	inc rsi
	loop _test
	
_found:
	nop
	
_code:
	egg: db 0xeb,0x02,0xeb,0xfc
