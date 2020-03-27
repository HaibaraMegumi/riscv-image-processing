.section .text
.globl _start
_start:

  li a0, 0x68
	 sb a0, 0(sp)
	# li a0, 0x6f
	# sb a0, 1(sp)
	# li a0, 0x6c
	# sb a0, 2(sp)
	# li a0, 0x61
	# sb a0, 3(sp)
	# li a0, 0x0a
	# sb a0, 4(sp)


	li a0, 0
	lui a1, %hi(path)            # load msg(hi)
	addi a1, a1, %lo(path)       # load msg(lo)
	li a2, 1026
	li a7, 56                 # _NR_sys_write
	ecall                       # system call

	mv a4, a0

	bgtz a0, y

n:	li a0, 0                    # stdout
	lui a1, %hi(no)                  # load msg(hi)
	addi a1, a1, %lo(no)       # load msg(lo)
	li a2, 15                   # length
	li a3, 0                    #
	li a7, 64                   # _NR_sys_write
	ecall                       # system call
	j end


y:li a0, 0                    # stdout
	lui a1, %hi(yes)                  # load msg(hi)
	addi a1, a1, %lo(yes)       # load msg(lo)
	li a2, 11                   # length
	li a3, 0                   #
	li a7, 64                   # _NR_sys_write
	ecall                       # system call

	mv a0, a4									#lseek
	li a1, 2
	li a2, 0
	li a7, 62
	ecall

	mv a0, a4							#read
	mv a1, sp
	li a2, 5
	li a7, 63
	ecall


	li a0, 0						#print
	mv a1, sp
	#lui a1, %hi(msg)                  # load msg(hi)
	#addi a1, a1, %lo(msg)       # load msg(lo)
	li a2, 5
	li a7, 64
	ecall



	li a7, 57
	ecall

end:	li a0, 0
	li a1, 0
	li a2, 0
	li a3, 0
	li a7, 93                   # _NR_sys_exit
	ecall                       # system call




.section .rodata
path:
	.string "/home/marco/Documents/projects/sharpening/IOTest/IO.txt"

yes:
	.string "File found\n"

no:
	.string "File not found\n"
msg:
	.string "New message in FilE\n"
