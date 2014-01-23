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
 movl $SYS_OPEN, %eax           # Call to open a file
 movl STACK_ARGV1(%ebp), %ebx    # Name of file
 movl $O_READONLY, %ecx         # Open Readonly
 movl $0666, %edx               # rw permissions for all, doesn't matter because reading
 int $LINUX_SYSCALL             # linux syscall

store_fd_in:
 movl %eax, STACK_FD_IN(%ebp)

open_fd_out:
 movl $SYS_OPEN, %eax
 movl STACK_ARGV2(%ebp), %ebx
 movl $O_CREATE_READ_WRITE_TRUNCATE, %ecx
 movl $0666, %edx
 int $LINUX_SYSCALL

store_fd_out:
 movl %eax, STACK_FD_OUT(%ebp)

### BEGIN MAIN LOOP ###
read_loop_begin:

# read a block from the input file
 movl $SYS_READ, %eax
 movl STACK_FD_IN(%ebp), %ebx
 movl $BUFFER_DATA, %ecx        # the location to read into
 movl $BUFFER_SIZE, %edx
 int $LINUX_SYSCALL

# exit if we've reached the end
 cmpl $EOF, %eax
 jle end_loop

continue_read_loop: # convert to upper case
 pushl $BUFFER_DATA
 pushl %eax             # contains the size of the buffer
 call convert_to_upper
 popl %eax
 addl $4, %esp

# write block to output file
 movl %eax, %edx    # Move size into edx
 movl $SYS_WRITE, %eax
 movl STACK_FD_OUT(%ebp), %ebx
 movl $BUFFER_DATA, %ecx
 int $LINUX_SYSCALL

###CONTINUE THE LOOP###
 jmp read_loop_begin

end_loop: 
# close the files 
# NOTE: errors don't signify anything special, so we don't have to worry about them
 movl $SYS_CLOSE, %eax
 movl STACK_FD_OUT(%ebp), %ebx
 int $LINUX_SYSCALL

 movl $SYS_CLOSE, %eax
 movl STACK_FD_IN(%ebp), %ebx
 int $LINUX_SYSCALL

# Exit
 movl $SYS_EXIT, %eax
 movl $0, %ebx
 int $LINUX_SYSCALL

### CASE CONVERSION FUNCTION ###
# Constants
 .equ LOWERCASE_A, 'a'
 .equ LOWERCASE_Z, 'z'
 .equ UPPER_CONVERSION, 'A' - 'a'

# stack junk
 .equ ST_BUFFER_LEN, 8  # Where the length of the buffer is stored
 .equ ST_BUFFER, 12     # The buffer

convert_to_upper:
 pushl %ebp
 movl %esp, %ebp

# Set up variables
 movl ST_BUFFER(%ebp), %eax
 movl ST_BUFFER_LEN(%ebp), %ebx
 movl $0, %edi

 cmpl $0, %ebx
 je end_convert_loop

convert_loop:
 #get the current byte
 movb (%eax,%edi,1), %cl    #cl because byte

 cmpb $LOWERCASE_A, %cl
 jl next_byte
 cmpb $LOWERCASE_Z, %cl
 jg next_byte

 addb $UPPER_CONVERSION, %cl
 movb %cl, (%eax,%edi,1)

next_byte:
 incl %edi
 cmpl %edi, %ebx
 jne convert_loop   #continues the loop unless you've reached the end of the buffer

end_convert_loop:
 movl %ebp, %esp
 popl %ebp
 ret
