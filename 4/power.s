 .section .data

 .section .text

 .globl _start
_start:
 pushl $0
 pushl $2
 call power

 movl %eax,%ebx
 movl $1,%eax
 int $0x80

 .type power, @function
power:
 pushl %ebp
 movl %esp,%ebp
 subl $4,%esp

 cmpl $0,8(%ebp)
 je zero_case

 movl 8(%ebp),%ebx
 movl 12(%ebp),%ecx
 movl %ebx,-4(%ebp)

power_loop_start:
 cmpl $1,%ecx
 je end_power
 movl -4(%ebp),%eax
 imul %ebx,%eax
 movl %eax,-4(%ebp)

 decl %ecx
 jmp power_loop_start

end_power:
 movl -4(%ebp),%eax
 movl %ebp,%esp
 popl %ebp
 ret

zero_case:
 movl $1,%eax
 movl %ebp,%esp
 popl %ebp
 ret
