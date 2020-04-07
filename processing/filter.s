.section .text
.globl _start
_start:

main:
        lui a1, %hi(input_path)           # load input path(hi)
        addi a1, a1, %lo(input_path)      # load input path(lo)
        jal open_file

        li t0, WIDTH
        li t1, HEIGHT
        mul t0, t0, t1
        sub sp, sp, t0
        mv a1, sp                         # set buffer address
        mv a2, t0                         # bytes to read
        li a7, 63                         # _NR_sys_read
        ecall                             # system call

        mv t0, sp
        addi sp, sp, -8
        sd t0, 0(sp)                      # store image file address

        lui a1, %hi(output_path)          # load output path(hi)
        addi a1, a1, %lo(output_path)     # load output path(lo)
        jal open_file

        addi sp, sp, -8
        sd a0, 0(sp)                      # store output file descriptor

# load kernel
        lui a1, %hi(kernel_path)          # load kernel path(hi)
        addi a1, a1, %lo(kernel_path)     # load kernel path(lo)
        jal open_file

        ld t0, 0(sp)                      # load output file descriptor
        addi sp, sp, 8
        ld t1, 0(sp)                      # load image file address
        addi sp, sp, 8


        addi sp, sp, -16
        mv a1, sp                          # set buffer address
        li a2, 9                           # bytes to read (kernel size)
        li a7, 63                          # _NR_sys_read
        ecall                              # system call

        li a0, 0
        mv a1, t1
        mv a2, sp #kernel address
        li a3, WIDTH
        li a4, HEIGHT
        mv a5, t0
        jal process_image

        addi sp, sp, 16 #delete kernel

        li t0, WIDTH
        li t1, HEIGHT
        mul t0, t0, t1
        add sp, sp, t0

        j end

process_image:
#input: a0 - pixel, a1 - file address, a2 - kernel address, a3 - columns(width),
#       a4 - rows(height), a5 - new file descriptor
        addi sp, sp, -40
        sd ra, 0(sp)
        mul a6, a3, a4              # calculate total pixels
loop:
        add a7, a1, a0              # add offset (calculate address of current pixel)
        bltz a0, end_loop             # return if pixel < 0
        bge a0, a6, end_loop          # return if pixel >= total pixels
        sd a0, 8(sp)
        sd a1, 16(sp)
        sd a2, 24(sp)
        sd a3, 32(sp)
        jal process_image_recursive
        jal write
        ld a0, 8(sp)
        ld a1, 16(sp)
        ld a2, 24(sp)
        ld a3, 32(sp)
        addi a0, a0, 1
        j loop
end_loop:
        ld ra, 0(sp)
        addi sp, sp, 40
        ret

process_image_recursive:
#input: a0 - pixel, a1 - file address, a2 - kernel address, a3 - columns(width),
#       a4 - rows(height), a6 - pixels, a7 - curr pixel address
        addi sp, sp, -8
        sd ra, 0(sp)

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

        jal convolve_center
        beqz t5, left_edge
        beqz t4, right_edge

        # accumulate central row
        jal convolve_right
        jal convolve_left

        bltz t3, top_edge
        bgez t2, bottom_edge

        jal convolve_top_left
        jal convolve_top
        jal convolve_top_right

        jal convolve_bottom_left
        jal convolve_bottom
        jal convolve_bottom_right
        j return

top_edge:
        jal convolve_bottom_left
        jal convolve_bottom
        jal convolve_bottom_right
        j return

bottom_edge:
        jal convolve_top_left
        jal convolve_top
        jal convolve_top_right
        j return

left_edge:
        jal convolve_right

        bltz t3, top_left_edge
        jal convolve_top
        jal convolve_top_right

        bgez t2, bottom_left_edge
        jal convolve_bottom
        jal convolve_bottom_right
        j return

top_left_edge:
        jal convolve_bottom
        jal convolve_bottom_right
        j return

bottom_left_edge:
        jal convolve_top
        jal convolve_top_right
        j return

right_edge:
        jal convolve_left

        bltz t3, top_right_edge
        jal convolve_top
        jal convolve_top_left

        bgez t2, bottom_right_edge
        jal convolve_bottom
        jal convolve_bottom_left
        j return

top_right_edge:
        jal convolve_bottom
        jal convolve_bottom_left
        j return

bottom_right_edge:
        jal convolve_top
        jal convolve_top_left
        j return

return:
        bgez t6, not_zero
        li t6, 0
not_zero:
        addi t0, t6, -255
        blez t0, not_255
        li t6, 255
not_255:
        mv a0, t6
        ld ra, 0(sp)
        addi sp, sp, 8
        ret

convolve_center:
        lbu t0, 0(a7)               # load the current pixel's value
        lb t1, 4(a2)                # load the kernel's central value
        mul t6, t1, t0              # multiply
        ret

convolve_right:
        lbu t0, 1(a7)               # load the next pixel's value
        lb t1, 5(a2)                # load the kernel's central-right value
        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate
        ret

convolve_left:
        lbu t0, -1(a7)              # load the previous pixel's value
        lb t1, 3(a2)                # load the kernel's central-left value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate
        ret

convolve_top:
        sub t5, a7, a3              # address of pixel above
        lbu t0, 0(t5)               # load the value of the pixel above
        lb t1, 1(a2)                # load the kernel's top-central value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate
        ret

convolve_bottom:
        add t5, a7, a3              # address of pixel below
        lbu t0, 0(t5)               # load the value of the pixel below
        lb t1, 7(a2)               # load the kernel's bottom-central value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate
        ret

convolve_top_left:
        sub t5, a7, a3              # address of pixel above
        lbu t0, -1(t5)               # load the value of the top-right diagonal pixel
        lb t1, 0(a2)                # load the kernel's top-right value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate
        ret

convolve_top_right:
        sub t5, a7, a3              # address of pixel above
        lbu t0, 1(t5)               # load the value of the top-right diagonal pixel
        lb t1, 2(a2)                # load the kernel's top-right value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate
        ret

convolve_bottom_left:
        add t5, a7, a3              # address of pixel below
        lbu t0, -1(t5)              # load the value of the bottom-left diagonal pixel
        lb t1, 6(a2)                # load the kernel's bottom-left value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate
        ret

convolve_bottom_right:
        add t5, a7, a3              # address of pixel below
        lbu t0, 1(t5)               # load the value of the bottom-right diagonal pixel
        lb t1, 8(a2)                # load the kernel's bottom-right value

        mul t0, t1, t0              # multiply
        add t6, t6, t0              # accumulate
        ret

end:
        li a0, 0
        li a1, 0
        li a2, 0
        li a3, 0
        li a7, 93                   # _NR_sys_exit
        ecall                       # system call
