# --------------------------------------------------------------------
# dc.s
#
# Desk Calculator (dc) (x86-64)
#
# Student ID: 20210645
# --------------------------------------------------------------------

    .equ   BUFFERSIZE, 32
    .equ   EOF, -1

# --------------------------------------------------------------------

.section ".rodata"

printrembyzero:
    .asciz "dc: remainder by zero\n"

printdivbyzero:
    .asciz "dc: divide by zero\n"

printoverflow:
    .asciz "dc: overflow happens\n"

printempty:
    .asciz "dc: stack empty\n"

printfFormat:
    .asciz "%d\n"

scanfFormat:
     .asciz "%s"

# --------------------------------------------------------------------

    .section ".data"

# --------------------------------------------------------------------

    .section ".bss"

# --------------------------------------------------------------------
    .section ".text"

    
    

    # -------------------------------------------------------------
    # int powerfunc(int base, int exponent)
    # Runs the power function.  Returns result.
    # -------------------------------------------------------------

    .globl	powerfunc
    .type   powerfunc, @function

    # base is stored in %rdi
    # exponent is stored in %rsi

powerfunc:

    ret            # return result

# -------------------------------------------------------------
# int main(void)
# Runs desk calculator program.  Returns 0.
# -------------------------------------------------------------

    .text
    .globl  main
    .type   main, @function

main:

    pushq   %rbp
    movq    %rsp, %rbp

    # char buffer[BUFFERSIZE]
    subq    $BUFFERSIZE, %rsp

    # Note %rsp must be 16-B aligned before call

.input:

    # while (1) {
    # scanf("%s", buffer)
    # %al must be set to 0 before scanf call

    leaq    scanfFormat, %rdi
    leaq    -BUFFERSIZE(%rbp), %rsi
    movb    $0, %al
    call    scanf


    # check if user input == EOF
    cmp	    $EOF, %eax
    je	    .quit


    # check buffer[0] is digit
    leaq    -BUFFERSIZE(%rbp), %rsi
    movb    (%rsi), %al
    cmp     $47, %al
    jle     .isnotdigit
    cmp     $57, %al
    ja      .isnotdigit
    jmp     .pushnumber


.isnotdigit:

    # seperate p, q, +, -, ...etc
    cmp     $'p', %al
    je      peek
    cmp     $'q', %al
    je      .quit
    cmp     $'+', %al
    je      add
    cmp     $'-', %al
    je      subtract
    cmp     $'*', %al
    je      multiply
    cmp     $'/', %al
    je      quotient
    cmp     $'%', %al
    je      remainder
    cmp     $'^', %al
    je      power
    cmp     $'_', %al
    je      minus
    cmp     $'f', %al
    je      printall
    cmp     $'c', %al
    je      clear
    jmp     .input
    



.quit:
    # return 0
    movq    $0, %rax
    addq    $BUFFERSIZE, %rsp
    movq    %rbp, %rsp
    popq    %rbp
    ret

# push integer in stack
.pushnumber:
    movq    $0, %rcx
    movq    $0, %rbx
    call    stringtoint
    subq    $8, %rsp
    pushq   %rcx
    jmp     .input

# change string to integer
stringtoint:

    # check the char is digit
    movb    -BUFFERSIZE(%rbp, %rbx, 1), %al
    cmp     $47, %al
    jle     ret_stringtoint
    cmp     $57, %al
    ja      ret_stringtoint

    # multifly 10
    movq    %rcx, %rdx
    addq    %rdx, %rcx
    addq    %rdx, %rcx
    addq    %rdx, %rcx
    addq    %rdx, %rcx
    addq    %rdx, %rcx
    addq    %rdx, %rcx
    addq    %rdx, %rcx
    addq    %rdx, %rcx
    addq    %rdx, %rcx

    subb    $'0', %al
    movzx   %al, %rax
    addq    %rax, %rcx
    addq    $1, %rbx
    jmp     stringtoint
    
ret_stringtoint:
    ret

peek:
    # check isempty 
    subq    $BUFFERSIZE, %rbp
    cmp     %rbp, %rsp
    je      isempty
    addq    $BUFFERSIZE, %rbp

    # print top of stack 
    leaq    printfFormat, %rdi
    movq    (%rsp), %rsi
    movb    $0, %al
    call    printf
    jmp     .input

# fprintf(stderr, "dc: stack empty\n")
isempty:
    addq    $BUFFERSIZE, %rbp
    movq    stderr, %rdi
    leaq    printempty, %rsi
    movb    $0, %al
    call    fprintf
    jmp     .input

add:
    # check len(stack) > 1
    subq    $BUFFERSIZE, %rbp
    cmp     %rbp, %rsp
    je      isempty
    movq    %rsp, %rcx
    addq    $16, %rcx
    cmp     %rbp, %rcx
    je      isempty
    addq    $BUFFERSIZE, %rbp

    # get the top two value
    popq    %rax
    addq    $8, %rsp
    popq    %rbx
    addq    $8, %rsp
    
    # add and store after check overflow
    addl    %ebx, %eax
    jo      overflow

    subq    $8, %rsp
    pushq   %rax

    jmp     .input

# fprintf(stderr, "dc: overflow happens\n")
overflow:
    movq    stderr, %rdi
    leaq    printoverflow, %rsi
    movb    $0, %al
    call    fprintf
    jmp     .quit


subtract:
    # check len(stack) > 1
    subq    $BUFFERSIZE, %rbp
    cmp     %rbp, %rsp
    je      isempty
    movq    %rsp, %rcx
    addq    $16, %rcx
    cmp     %rbp, %rcx
    je      isempty
    addq    $BUFFERSIZE, %rbp

    # get the top two value
    popq    %rax
    addq    $8, %rsp
    popq    %rbx
    addq    $8, %rsp

    # subtract and store after check overflow
    subl    %eax, %ebx
    jo      overflow

    subq    $8, %rsp
    pushq   %rbx

    jmp     .input

multiply:
    # check len(stack) > 1
    subq    $BUFFERSIZE, %rbp
    cmp     %rbp, %rsp
    je      isempty
    movq    %rsp, %rcx
    addq    $16, %rcx
    cmp     %rbp, %rcx
    je      isempty
    addq    $BUFFERSIZE, %rbp

    # get the top two value
    popq    %rax
    addq    $8, %rsp    
    popq    %rbx
    addq    $8, %rsp
    
    # multifly and store after check overflow
    imull   %ebx
    jo      overflow

    subq    $8, %rsp
    pushq   %rax

    jmp     .input

quotient:
    # check len(stack) > 1
    subq    $BUFFERSIZE, %rbp
    cmp     %rbp, %rsp
    je      isempty
    movq    %rsp, %rcx
    addq    $16, %rcx
    cmp     %rbp, %rcx
    je      isempty
    addq    $BUFFERSIZE, %rbp

    # get the top two value and check divider is 0
    popq    %rbx
    addq    $8, %rsp
    cmp     $0, %rbx
    je      divbyzero
    popq    %rax
    addq    $8, %rsp

    # divide and store after check overflow
    cltd
    idivl   %ebx
    jo      overflow

    subq    $8, %rsp
    pushq   %rax

    jmp     .input

# fprintf(stderr, "dc: divide by zero\n")
divbyzero:
    movq    stderr, %rdi
    leaq    printdivbyzero, %rsi
    movb    $0, %al
    call    fprintf
    jmp     .quit


remainder:
    # check len(stack) > 1
    subq    $BUFFERSIZE, %rbp
    cmp     %rbp, %rsp
    je      isempty
    movq    %rsp, %rcx
    addq    $16, %rcx
    cmp     %rbp, %rcx
    je      isempty
    addq    $BUFFERSIZE, %rbp

    # get the top two value and check divider is 0
    popq    %rbx
    addq    $8, %rsp
    cmp     $0, %rbx
    je      rembyzero
    popq    %rax
    addq    $8, %rsp
    movq    $0, %rdx

    # seperate the case when dividend is negative
    cmp     $0, %rax
    jl      negative_remainder

    # get remainder and store
    idivq   %rbx

    subq    $8, %rsp
    pushq   %rdx

    jmp     .input

negative_remainder:
    negq    %rax
    idivq   %rbx
    negq    %rdx

    subq    $8, %rsp
    pushq   %rdx

    jmp     .input
    
# fprintf(stderr, "dc: remainder by zero\n")
rembyzero:
    movq    stderr, %rdi
    leaq    printrembyzero, %rsi
    movb    $0, %al
    call    fprintf
    jmp     .quit

power:
    # check len(stack) > 1
    subq    $BUFFERSIZE, %rbp
    cmp     %rbp, %rsp
    je      isempty
    movq    %rsp, %rcx
    addq    $16, %rcx
    cmp     %rbp, %rcx
    je      isempty
    addq    $BUFFERSIZE, %rbp

    # get the top two value
    popq    %rbx
    addq    $8, %rsp
    popq    %rcx    
    addq    $8, %rsp
    movq    %rcx, %rax

    # calculate power by using loop label and store
    # after check overflow
    cmp     $0, %rbx
    ja      powerloop

    subq    $8, %rsp
    pushq   $1

    jmp     .input

powerloop:
    cmp     $1, %rbx
    je      powerresult
    imull   %ecx
    jo      overflow
    subq    $1, %rbx
    jmp     powerloop


powerresult:
    subq    $8, %rsp
    pushq   %rax

    jmp     .input

# when '_' is input, change to negative integer
minus:
    movq    $0, %rcx
    movq    $1, %rbx
    call    stringtoint
    negq    %rcx

    subq    $8, %rsp
    pushq   %rcx

    jmp     .input

# print every stack element by using loop label
printall:
    subq    $BUFFERSIZE, %rbp
    movq    %rsp, %r13
    call    printloop
    jmp     .input

printloop:
    leaq    printfFormat, %rdi
    movq    (%r13), %rsi
    movb    $0, %al
    call    printf

    addq    $16, %r13
    cmp     %rbp,%r13
    jae     endofprint
    jmp     printloop

endofprint:
    addq    $BUFFERSIZE, %rbp
    ret

# clear the stack
clear:
    movq    %rbp, %rsp
    subq    $BUFFERSIZE, %rsp
    jmp     .input
