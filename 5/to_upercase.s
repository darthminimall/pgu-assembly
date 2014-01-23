.section .data
# system calls
 .equ SYS_OPEN, 5
 .equ SYS_WRITE, 4
 .equ SYS_READ, 3
 .equ SYS_CLOSE, 6
 .equ SYS_EXIT, 1

# open options
 .equ O_READONLY, 0
 .equ O_CREATE_READ_WRITE_TRUNCATE, 03101

# standard file descriptors
 .equ STDIN, 0
 .equ STDOUT, 1
 .equ STDERR, 2

# syscall interupt
 .equ LINUX_SYSCALL, 0x80

 .equ EOF, 0
 .equ NUM_ARGUMENTS, 2

.section .bss
# buffer
 .equ BUFFER_SIZE, 500
 .lcomm BUFFER_DATA, BUFFER_SIZE

.section .text
 .equ STACK_SIZE_RESERVE, 8
 .equ STACK_FD_IN, -4
 .equ STACK_FD_OUT, -8
 .equ STACK_ARGC, 0     # number of args
 .equ STACK_ARGV0, 4    # name of program
 .equ STACK_ARGV1, 8    # name of input file
 .equ STACK_ARGV2, 12   # name of output file

 .globl _start
_start:
 # save stack pointer
 mov %esp, %ebp

 # reserve space on stack
 subl $STACK_SIZE_RESERVE, %esp

open_files:
open_fd_in:
 movl $SYS_OPEN, %eax
 movl STACK_ARGV1(ebp), %ebx
 movl $O_READONLY, %ecx
 movl $0666, %edx
