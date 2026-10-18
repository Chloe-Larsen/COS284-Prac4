BITS 64
global readDfa:function
extern fopen, fclose, fseek, ftell, fread, malloc, free
section .rodata
mode_r:     db "r", 0

    section .text

readDfa:
    push rbp
    mov  rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub  rsp, 72
    
    mov  r12, rdi
    
    lea  rsi, [rel mode_r]
    call fopen
    test rax, rax
    jz   .ret_null
    mov  rbx, rax
    
    mov  rdi, rbx
    xor  esi, esi
    mov  edx, 2
    call fseek
    
    mov  rdi, rbx
    call ftell
    lea  r13, [rax + 1]
    
    mov  rdi, rbx
    xor  esi, esi
    xor  edx, edx
    call fseek
    
    mov  rdi, r13
    call malloc
    test rax, rax
    jz   .fclose_null
    mov  r12, rax
    
    mov  rdi, r12
    mov  esi, 1
    mov  rdx, r13
    mov  rcx, rbx
    call fread    
    mov  byte [r12 + rax], 0
    
    lea  rax, [r12]
    mov  [rbp-48], rax
    
    lea  rdi, [rbp-48]
    call next_int
    mov  [rbp-8], eax
    
    lea  rdi, [rbp-48]
    call next_int
    mov  [rbp-16], eax
    
    mov  edi, 32
    call malloc
    test rax, rax
    jz   .free_buf_null
    mov  [rbp-24], rax

    mov  eax, [rbp-8]
    shl  eax, 3
    test eax, eax
    jnz  .alloc_states
    xor  edi, edi
    mov  qword [rbp-32], 0
    jmp  .alloc_trans
.alloc_states:
    movsxd rdi, eax
    call malloc
    test rax, rax
    jz   .free_dfa_buf_null
    mov  [rbp-32], rax

.alloc_trans:    
    mov  eax, [rbp-16]
    imul eax, eax, 12
    test eax, eax
    jnz  .alloc_trans_real
    mov  qword [rbp-40], 0
    jmp  .fill_header
.alloc_trans_real:
    movsxd rdi, eax
    call malloc
    test rax, rax
    jz   .free_states_dfa_buf_null
    mov  [rbp-40], rax

.fill_header:
    mov  rax, [rbp-24]
    mov  rdx, [rbp-32]
    mov  [rax + 0], rdx
    mov  rdx, [rbp-40]
    mov  [rax + 8], rdx
    mov  edx, [rbp-8]
    mov  [rax + 16], edx
    mov  edx, [rbp-16]
    mov  [rax + 20], edx
    mov  dword [rax + 24], 0
    
    xor  ecx, ecx
    mov  rdx, [rbp-32]
    test rdx, rdx
    jz   .fill_states_done
.fill_states:
    cmp  ecx, [rbp-8]
    jge  .fill_states_done
    mov  [rdx], ecx
    mov  byte [rdx + 4], 0
    add  rdx, 8
    inc  ecx
    jmp  .fill_states
.fill_states_done:

.skip_line1:
    mov  rax, [rbp-48]
    movzx edx, byte [rax]
    test dl, dl
    jz   .acc_done
    inc  rax
    mov  [rbp-48], rax
    cmp  dl, 10
    jne  .skip_line1
    
.skip_line2:
    mov  rax, [rbp-48]
    movzx edx, byte [rax]
    test dl, dl
    jz   .acc_done
    inc  rax
    mov  [rbp-48], rax
    cmp  dl, 10
    jne  .skip_line2

.acc_loop:
    mov  rax, [rbp-48]
    movzx edx, byte [rax]
    test dl, dl
    jz   .acc_done
    cmp  dl, 10
    je   .acc_done
    cmp  dl, 13
    je   .acc_adv
    cmp  dl, ','
    je   .acc_adv
    cmp  dl, ' '
    je   .acc_adv
    cmp  dl, 9
    je   .acc_adv    
    lea  rdi, [rbp-48]
    call next_int
    mov  rdx, [rbp-32]
    test rdx, rdx
    jz   .acc_loop
    mov  ecx, eax
    shl  ecx, 3
    movsxd rcx, ecx
    add  rdx, rcx
    mov  byte [rdx + 4], 1
    jmp  .acc_loop
.acc_adv:
    inc  rax
    mov  [rbp-48], rax
    jmp  .acc_loop

.acc_done:
    mov  rax, [rbp-48]
    cmp  byte [rax], 10
    jne  .acc_done2
    inc  rax
    mov  [rbp-48], rax
.acc_done2:
    mov  dword [rbp-56], 0
.trans_loop:
    mov  ecx, [rbp-56]
    cmp  ecx, [rbp-16]
    jge  .trans_done
    
    mov  rax, [rbp-48]
    cmp  byte [rax], 0
    je   .trans_done
    
    lea  rdi, [rbp-48]
    call next_int
    mov  r14d, eax
    
    lea  rdi, [rbp-48]
    call next_int
    mov  r15d, eax
    
    lea  rdi, [rbp-48]
    call next_symbol

    mov  ecx, [rbp-56]
    imul ecx, ecx, 12
    movsxd rcx, ecx
    add  rcx, [rbp-40]
    mov  [rcx + 0], r14d
    mov  [rcx + 4], r15d
    mov  [rcx + 8], al

    inc  dword [rbp-56]
    jmp  .trans_loop
.trans_done:    
    mov  rdi, r12
    call free

    mov  rdi, rbx
    call fclose

    mov  rax, [rbp-24]
    jmp  .epilogue
    
.free_states_dfa_buf_null:
    mov  rdi, [rbp-32]
    test rdi, rdi
    jz   .free_dfa_buf_null
    call free
.free_dfa_buf_null:
    mov  rdi, [rbp-24]
    test rdi, rdi
    jz   .free_buf_null
    call free
.free_buf_null:
    mov  rdi, r12
    call free
.fclose_null:
    mov  rdi, rbx
    call fclose
.ret_null:
    xor  eax, eax

.epilogue:
    add  rsp, 72
    pop  r15
    pop  r14
    pop  r13
    pop  r12
    pop  rbx
    pop  rbp
    ret

next_int:
    mov  rsi, [rdi]
.ni_skip:
    movzx eax, byte [rsi]
    test al, al
    jz   .ni_zero
    cmp  al, '-'
    je   .ni_neg
    cmp  al, '0'
    jl   .ni_adv
    cmp  al, '9'
    jle  .ni_pos
.ni_adv:
    inc  rsi
    jmp  .ni_skip
.ni_neg:
    inc  rsi
    xor  r8d, r8d
.ni_neg_loop:
    movzx eax, byte [rsi]
    cmp  al, '0'
    jl   .ni_neg_end
    cmp  al, '9'
    jg   .ni_neg_end
    imul r8d, r8d, 10
    sub  al, '0'
    movzx eax, al
    add  r8d, eax
    inc  rsi
    jmp  .ni_neg_loop
.ni_neg_end:
    neg  r8d
    mov  [rdi], rsi
    mov  eax, r8d
    ret
.ni_pos:
    xor  r8d, r8d
.ni_pos_loop:
    movzx eax, byte [rsi]
    cmp  al, '0'
    jl   .ni_pos_end
    cmp  al, '9'
    jg   .ni_pos_end
    imul r8d, r8d, 10
    sub  al, '0'
    movzx eax, al
    add  r8d, eax
    inc  rsi
    jmp  .ni_pos_loop
.ni_pos_end:
    mov  [rdi], rsi
    mov  eax, r8d
    ret
.ni_zero:
    mov  [rdi], rsi
    xor  eax, eax
    ret

next_symbol:
    mov  rsi, [rdi]
.ns_loop:
    movzx eax, byte [rsi]
    test al, al
    jz   .ns_eof
    cmp  al, ','
    je   .ns_adv
    cmp  al, 10
    je   .ns_adv
    cmp  al, 13
    je   .ns_adv
    cmp  al, ' '
    je   .ns_adv
    cmp  al, 9
    je   .ns_adv
    inc  rsi
    mov  [rdi], rsi
    ret
.ns_adv:
    inc  rsi
    jmp  .ns_loop
.ns_eof:
    xor  eax, eax
    mov  [rdi], rsi
    ret