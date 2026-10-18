BITS 64
global simulateDfa:function

section .text
simulateDfa:
    push rbp
    mov  rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub  rsp, 8

    mov  r12, rdi
    mov  r13, rsi
    mov  r14d, [r12 + 24]

.loop:
    movzx eax, byte [r13]
    test al, al
    jz   .accept

    mov  rbx, [r12 + 8]
    mov  r15d, [r12 + 20]
    xor  ecx, ecx
.find:
    cmp  ecx, r15d
    jge  .reject    
    mov  edx, ecx
    imul edx, edx, 12
    movsxd rdx, edx
    add  rdx, rbx
    cmp  dword [rdx + 0], r14d
    jne  .next
    cmp  byte  [rdx + 8], al
    jne  .next
    mov  r14d, [rdx + 4]
    jmp  .advance
.next:
    inc  ecx
    jmp  .find

.advance:
    inc  r13
    jmp  .loop

.accept:    
    mov  rax, [r12 + 0]
    mov  ecx, r14d
    shl  ecx, 3
    movsxd rcx, ecx
    add  rax, rcx
    movzx eax, byte [rax + 4]
    jmp  .done

.reject:
    xor  eax, eax

.done:
    add  rsp, 8
    pop  r15
    pop  r14
    pop  r13
    pop  r12
    pop  rbx
    pop  rbp
    ret    