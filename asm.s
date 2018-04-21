section .data
    epsilonFs: db "epsilon = %lf", 10, 0
    orderFs: db "order = %ld", 10, 0
    initFs: db "initial = %lf %lf", 10, 0
    coeffFs: db "coeff %ld = %lf %lf", 10, 0
    _0: dq 0.0
    _1: dq 1.0

section .bss
    epsilon: resq 1         ; double epsilon
    initial: resq 2         ; Complex { double real, double img }
    polynom: resq 2         ; { long order, Complex *coeff }
    derivative: resq 2      ; { long order, Complex *coeff }

section .text
    global complexMul, power, computePoly, deriviate
    extern scanf, printf, calloc, free

; Complex complexMul(Complex *c1, Complex *c2)
complexMul:
    push rbp
    mov rbp, rsp
    
    movsd xmm4, qword [rdi]
    movsd xmm2, qword [rdi+8]
    movsd xmm1, qword [rsi]
    movsd xmm3, qword [rsi+8]
    movapd xmm0, xmm4
    mulsd xmm0, xmm1
    movapd xmm5, xmm2
    mulsd xmm5, xmm3
    subsd xmm0, xmm5
    mulsd xmm3, xmm4
    mulsd xmm1, xmm2
    addsd xmm1, xmm3
    
    pop rbp
    ret

; Complex power(Complex *c, long pow)
power:
    push rbp
    mov rbp, rsp

    sub rsp, 16
    movsd xmm0, [_1]
    movsd xmm1, [_0]
    movsd qword [rbp - 16], xmm0
    movsd qword [rbp - 8], xmm1
    cmp rsi, 0
    je .done

    mov rcx, rsi
    .loop:
        lea rsi, [rbp - 16]
        call complexMul
        movsd qword [rbp - 16], xmm0
        movsd qword [rbp - 8], xmm1
        loop .loop, rcx
    
    movsd xmm0, qword [rbp - 16]
    movsd xmm1, qword [rbp - 8]

    .done:
        mov rsp, rbp
        pop rbp
        ret

; Complex computePoly(Complex *c, Polynom *p)
computePoly:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    movsd xmm0, [_0]
    movsd xmm1, [_0]
    movsd qword [rbp - 16], xmm0
    movsd qword [rbp - 8], xmm1
    
    mov rcx, [rsi]              ; polynom.order
    inc rcx
    mov r9, [rsi + 8]           ; polynom.coeff array
    mov r10, rdi
    mov r11, 0
    .loopPoly:
        mov rsi, r11            ; Coeff index
        mov rdi, r10            ; Complex *c
        mov r12, rcx
        call power
        movsd qword [rbp - 32], xmm0
        movsd qword [rbp - 24], xmm1
        lea rdi, [rbp - 32]      ; Complex *temp
        mov rax, 16
        mul r11
        lea rsi, [r9 + rax]     ; polynom.coeff[index]
        call complexMul
        movsd xmm2, qword [rbp - 16]
        addsd xmm2, xmm0    ; Adding real parts
        movsd qword [rbp - 16], xmm2
        movsd xmm3, qword [rbp - 8]
        addsd xmm3, xmm1     ; Adding img parts
        movsd qword [rbp - 8], xmm3
        inc r11
        mov rcx, r12
        loop .loopPoly, rcx
    
    movsd xmm0, qword [rbp - 16]
    movsd xmm1, qword [rbp - 8]

    .done:
        mov rsp, rbp
        pop rbp
        ret

main1:
    push rbp
    mov rbp, rsp

    ; Scan epsilon
    mov rdi, epsilonFs
    mov rsi, epsilon
    mov rax, 0
    call scanf

    ; Scan order
    mov rdi, orderFs
    mov rsi, polynom
    mov rax, 0
    call scanf

    ; Scan coeffs
    mov rdi, [polynom]
    inc rdi
    mov rsi, 16
    call calloc         ; calloc(p->order + 1, sizeof(Complex))
    mov [polynom + 8], rax

    mov rcx, [polynom]
    inc rcx
    sub rsp, 32
    .coeff_loop:
        mov rdi, coeffFs
        lea rsi, [rbp - 24]
        lea rdx, [rbp - 16]
        mov qword [rbp - 8], rcx   ; Save loop index
        lea rcx, [rbp - 32]
        mov eax, 0
        call scanf      ; scanf(&coeffFs, &index, &c.real, &c.imaginery)
        mov rax, [rbp - 24]  ; index
        mov rbx, 16
        mul rbx
        mov r8, [polynom + 8]   ; polynom.coeff
        mov r9, [rbp - 16]
        mov qword [r8 + rax], r9 ; Save real part to polynom.coeff[index]
        add r8, 8
        mov r9, [rbp - 32]
        mov qword [r8 + rax], r9 ; Save img part to polynom.coeff[index]+8
        
        mov rcx, [rbp - 8]     ; Restore loop index
        loop .coeff_loop, rcx

    mov rdi, initFs
    mov rsi, initial
    lea rdx, [initial + 8]
    mov eax, 0
    call scanf

    call printPoly
    
    mov rax, 60
    syscall

deriviate:
    push rbp
    mov rbp, rsp

    ; mov rax, [rdi]                ; For C debugging
    ; mov [polynom], rax
    ; mov rax, [rdi + 8]
    ; mov [polynom + 8], rax
    mov rax, [polynom]   ; Copy order
    dec rax
    mov [derivative], rax
    
    cmp qword [polynom], 0
    jne .notZero
    
    inc qword [derivative]
    mov rsi, 16                         ; sizeof(Complex)
    mov rdi, 1
    call calloc
    mov [derivative + 8], rax
    mov r8 ,[derivative + 8]
    movsd xmm0, [_0]
    movsd xmm1, [_0]
    movsd qword [r8], xmm0
    movsd qword [r8 + 8], xmm1
    jmp .done

    .notZero:
        mov r12, 1                      ; loop index
        mov rsi, 16                         ; sizeof(Complex)
        mov rdi, [derivative]
        inc rdi
        call calloc
        mov [derivative + 8], rax
        mov rcx, [polynom]              ; polynom.order
        mov r8, [derivative + 8]        ; derivative.coeff array
        mov r9, [polynom + 8]           ; polynom.coeff array
        .loopDerivative:
            mov rax, 16
            mul r12
            mov rbx, [r9 + rax]       ; Transfer real value
            mov qword [r8 + rax - 16], rbx
            mov rbx, [r9 + rax + 8]    ; Transfer img value
            mov qword [r8 + rax - 8], rbx
            movsd xmm0, [r8 + rax - 16]
            cvtsi2sd xmm1, r12
            mulsd xmm0, xmm1            ; Multiple real value by index
            movsd [r8 + rax - 16], xmm0
            movsd xmm0, [r8 + rax - 8]
            cvtsi2sd xmm1, r12
            mulsd xmm0, xmm1            ; Multiple img value by index
            movsd [r8 + rax - 8], xmm0
            inc r12
            loop .loopDerivative, rcx
    
    .done:
        call printDer
        mov rsp, rbp
        pop rbp
        ret

printPoly:
    push rbp
    mov rbp, rsp

    mov rdi, epsilonFs
    movsd xmm0, QWORD [epsilon]
    mov eax,1
    call printf 

    mov rdi, orderFs
    mov rsi, [polynom]
    call printf

    mov rcx, [polynom]
    inc rcx
    mov r12, [polynom+8]
    mov rsi, 0
    .coeff_loop:
        mov edi, coeffFs
        movsd xmm0, QWORD [r12]
        movsd xmm1, QWORD [r12 + 8]
        mov eax, 2
        push rsi
        push rcx
        call printf
        pop rcx
        pop rsi
        add r12, 16
        inc rsi
        loop .coeff_loop, rcx

    movsd xmm0, QWORD [initial]
    movsd xmm1, QWORD [initial + 8]
    mov edi, initFs
    mov eax, 2
    call printf
    
    mov rsp,rbp
    pop rbp
    ret

printDer:
    push rbp
    mov rbp, rsp

    mov rdi, orderFs
    mov rsi, [derivative]
    call printf

    mov rcx, [derivative]
    inc rcx
    mov r12, [derivative + 8]
    mov rsi, 0
    .coeff_loop:
        mov edi, coeffFs
        movsd xmm0, qword [r12]
        movsd xmm1, qword [r12 + 8]
        mov eax, 2
        push rsi
        push rcx
        call printf
        pop rcx
        pop rsi
        add r12, 16
        inc rsi
        loop .coeff_loop, rcx
    
    mov rsp,rbp
    pop rbp
    ret