.section .rodata
input_path:
   .string "$$INPUT$$"
output_path:
   .string "$$OUTPUT$$"
kernel_path:
  .string "/home/mherrera/Documents/projects/sharpening/processing/.kernel"
file_found:
	.string "File found\n"
file_not_found:
	.string "File not found\n"

.section .text
    .equ WIDTH, 100
    .equ HEIGHT, 100
