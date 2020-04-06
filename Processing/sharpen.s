.section .text
.globl _start
_start:

main:

        lui a1, %hi(path)           # load path(hi)
        addi a1, a1, %lo(path)      # load path(lo)
        jal open_file


        li sp, 0x7efffff0000f
        mv s0, a0					 # load file descriptor id
        addi a1, sp, 110                    # set buffer address
        #li a2, 606697                     # bytes to read
        li a2, 10000                     # bytes to read
        li a7, 63                    # _NR_sys_read
        ecall                        # system call

        lui a1, %hi(path2)           # load path(hi)
        addi a1, a1, %lo(path2)      # load path(lo)
        jal open_file
        mv t6, a0

        # load kernel
        # li t0, -1
        # sb t0, 101(sp)
        # sb t0, 103(sp)
        # sb t0, 105(sp)
        # sb t0, 107(sp)
        # li t0, 0
        # sb t0, 100(sp)
        # sb t0, 102(sp)
        # sb t0, 106(sp)
        # sb t0, 108(sp)
        # li t0, 5
        # sb t0, 104(sp)

        # li a0, 0							#read
    	# mv a1, sp
    	# li a2, 20
    	# li a7, 63
    	# ecall
        #
        # li a0, 0							#print
        # mv a1, sp
        # li a2, 20
        # li a7, 64
        # ecall


        li t0, -1
        sb t0, 101(sp)
        sb t0, 103(sp)
        sb t0, 105(sp)
        sb t0, 107(sp)
        sb t0, 100(sp)
        sb t0, 102(sp)
        sb t0, 106(sp)
        sb t0, 108(sp)
        li t0, 8
        sb t0, 104(sp)

        li a0, 0
        addi a1, sp, 110
        addi a2, sp, 100
        li a3, 100
        li a4, 100
        mv a5, t6
        jal process_image

        j end

process_image:
#input: a0 - pixel, a1 - file address, a2 - kernel address, a3 - columns(width),
#       a4 - rows(height), a5 - new file descriptor
        addi sp, sp, 4
        sw ra, -4(sp)
        mul a6, a3, a4              # calculate total pixels
        add a7, a1, a0              # add offset (calculate address of current pixel)
        bltz a0, end             # return if pixel < 0
        bge a0, a6, end          # return if pixel >= total pixels
        jal process_image_recursive
        addi sp, sp, -4
        lw ra, 0(sp)
        ret

process_image_recursive:
#input: a0 - pixel, a1 - file address, a2 - kernel address, a3 - columns(width),
#       a4 - rows(height), a5 - new file descriptor, a6 - pixels, a7 - curr pixel address
        addi sp, sp, 4
        sw ra, -4(sp)
loop:
        bge a0, a6, return          # return if pixel >= total pixels

#calculate flags (t5, t4, t3, t2) to determine if pixel is at any edge (left, right, top, bottom)

        rem t5, a0, a3              # calculate reminder of current pixel divided by #columns
                                    # if t5 == 0 then current pixel is at left edge of image

        add t4, a0, 1               # next pixel
        rem t4, t4, a3              # calculate reminder of next pixel divided by #columns
                                    # if t4 == 0 then current pixel is at right edge of image

        sub t3, a0, a3              # pixel above current pixel (current - columns)
                                    # if t3 < 0 current pixel is at the top of the image

        add t2, a0, a3              # pixel below current pixel (current + columns)
        sub t2, t2, a6              # substract total amount of pixels
                                    # if t2 >= 0 current pixel is at the bottom of the image

        lbu t0, 0(a7)               # load the current pixel's value
        lb t1, 4(a2)               # load the kernel's central value

#t6 represents acummulate of convolution
        mul t6, t1, t0              # convolution

        beqz t5, left_edge
        beqz t4, right_edge

        lbu t0, 1(a7)               # load the next pixel's value
        lb t1, 5(a2)               # load the kernel's central-right value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate

        lbu t0, -1(a7)              # load the previous pixel's value
        lb t1, 3(a2)               # load the kernel's central-left value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate

        bltz t3, top_edge
        bgez t2, bottom_edge

        jal convolve_top_left
        sub t5, a7, a3              # address of pixel above
        lbu t0, 1(t5)               # load the value of the top-right diagonal pixel
        lb t1, 2(a2)               # load the kernel's top-right value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate
        jal convolve_bottom_right
        add t5, a7, a3              # address of pixel below
        lbu t0, -1(t5)              # load the value of the bottom-left diagonal pixel
        lb t1, 6(a2)               # load the kernel's bottom-left value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate

        j loopback

top_edge:
        jal convolve_bottom_left
        add t5, a7, a3              # address of pixel below
        lbu t0, 1(t5)               # load the value of the bottom-right diagonal pixel
        lb t1, 8(a2)               # load the kernel's bottom-right value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate

        j loopback

bottom_edge:
        jal convolve_top_left
        sub t5, a7, a3              # address of pixel above

        lbu t0, 1(t5)               # load the value of the top-right diagonal pixel
        lb t1, 2(a2)               # load the kernel's top-right value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate

        j loopback

left_edge:
        lbu t0, 1(a7)               # load the next pixel's value
        lb t1, 5(a2)               # load the kernel's central-right value

#t6 represents acummulate of convolution
        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate

        bltz t3, top_left_edge
        jal convolve_top_right

        bgez t2, bottom_left_edge
        jal convolve_bottom_right
        j loopback


top_left_edge:
        jal convolve_bottom_right
        j loopback

convolve_bottom_right:
        add t5, a7, a3              # address of pixel below
        lbu t0, 0(t5)               # load the value of the pixel below
        lb t1, 7(a2)               # load the kernel's bottom-central value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate

        lbu t0, 1(t5)               # load the value of the bottom-right diagonal pixel
        lb t1, 8(a2)               # load the kernel's bottom-right value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate
        ret

convolve_top_right:
        sub t5, a7, a3              # address of pixel above
        lbu t0, 0(t5)               # load the value of the pixel above
        lb t1, 1(a2)               # load the kernel's top-central value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate

        lbu t0, 1(t5)               # load the value of the top-right diagonal pixel
        lb t1, 2(a2)               # load the kernel's top-right value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate
        ret

bottom_left_edge:
        jal convolve_top_right
        j loopback

right_edge:
        lbu t0, -1(a7)              # load the previous pixel's value
        lb t1, 3(a2)               # load the kernel's central-left value

        #t6 represents acummulate of convolution
        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate

        bltz t3, top_right_edge
        jal convolve_top_left

        bgez t2, bottom_right_edge
        jal convolve_bottom_left
        j loopback

top_right_edge:
        jal convolve_bottom_left
        j loopback

bottom_right_edge:
        jal convolve_top_left
        j loopback

convolve_top_left:
        sub t5, a7, a3              # address of pixel above
        lbu t0, 0(t5)               # load the value of the pixel above
        lb t1, 1(a2)               # load the kernel's top-central value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate

        lbu t0, -1(t5)              # load the value of the top-left diagonal pixel
        lb t1, 0(a2)               # load the kernel's top-left value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate
        ret

convolve_bottom_left:
        add t5, a7, a3              # address of pixel below
        lbu t0, 0(t5)               # load the value of the pixel below
        lb t1, 7(a2)               # load the kernel's bottom-central value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate

        lbu t0, -1(t5)              # load the value of the bottom-left diagonal pixel
        lb t1, 6(a2)               # load the kernel's bottom-left value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate
        ret

loopback:
        bltz t6, crop_zero
        addi t0, t6, -255
        bgtz t0, crop_255
        j write
crop_zero:
        li t6, 0
        j write
crop_255:
        li t6, 255
        j write
write:
        lbu t0, 0(sp)
        sb t6, 0(sp)

        mv t1, a0
        mv t2, a1
        mv t3, a2
        mv t4, a3
        mv t5, a7

        mv a0, a5
        mv a1, sp
        li a2, 1                    # length
        li a3, 0
        li a7, 64                   # _NR_sys_write
        ecall

        sb t0, 0(sp)

        mv a0, t1
        mv a1, t2
        mv a2, t3
        mv a3, t4
        mv a7, t5

        addi a0, a0, 1
        add a7, a1, a0              # add offset (calculate address of current pixel)
        j loop

return:
        addi sp, sp, -4
        lw ra, 0(sp)
        ret


end:
        li a0, 0
        li a1, 0
        li a2, 0
        li a3, 0
        li a7, 93                   # _NR_sys_exit
        ecall                       # system call
