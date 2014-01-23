 .section .data

 .section .text
 .globl _start

_start:
 pushl $5

 call factorial

 movl %eax,%ebx
 movl $1,%eax

 int $0x80

 # Takes one argument, the number
 .type factorial,@function
factorial:
 pushl %ebp
 movl %esp,%ebp

 # if the call number is 1, return 1
 cmpl $1,8(%ebp)
 je factorial_exit_case

 movl 8(%ebp),%ebx
 decl %ebx
 pushl %ebx

 call factorial

 imull 8(%ebp),%eax

 movl %ebp,%esp
 popl %ebp

 ret

factorial_exit_case:
 movl %ebp,%esp
 popl %ebp

 movl $1,%eax
 ret

