section .data
    epsilonFs: db "epsilon = %lf", 10, 0
    orderFs: db "order = %ld", 10, 0
    initFs: db "initial = %lf %lf", 10, 0
    coeffFs: db "coeff %ld = %lf %lf", 10, 0

section .bss
    epsilon: resq 1
    order: resq 1
    initReal: resq 2
    initImg: resq 2

section .text
    global main
    extern scanf, printf

main:
    push rbp
    mov rbp, rsp

    mov rdi, epsilonFs
    mov rsi, epsilon
    mov rax, 0
    call scanf
    mov rdi, epsilonFs
    mov rsi, [epsilon]
    call printf

    mov rdi, orderFs
    mov rsi, order
    mov rax, 0
    call scanf
    mov rdi, orderFs
    mov rsi, [order]
    call printf

    mov rdi, initFs
    mov rsi, initReal
    mov rdx, initImg
    mov eax, 0
    call scanf
    movsd xmm1, QWORD [initImg]
    movsd xmm0, QWORD [initReal]
    mov edi, initFs
    mov eax, 2
    call printf
    
    mov rax, 60
    syscall