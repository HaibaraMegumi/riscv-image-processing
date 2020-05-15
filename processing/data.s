.section .rodata
input_path:
   .string "raw_unfiltered"
output_path:
   .string "raw_filtered"
kernel_path:
  .string ".kernel"
file_found:
	.string "File found\n"
file_not_found:
	.string "File not found\n"

.section .text
    .equ BUFFER_SIZE, 650000
