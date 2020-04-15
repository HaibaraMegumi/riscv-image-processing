import kernel_handler
import image_handler
import fileinput
import argparse
import os


# Construct the argument parser
ap = argparse.ArgumentParser()

# Add the arguments to the parser
ap.add_argument("-i", "--img-path", required=True,
   help="absolute or relative path to image")

ap.add_argument("-k", "--kernel-id", required=False,
   help="kernel identifier")
ap.add_argument("-o", "--output", required=False,
  help="absolute or relative path to output file")
ap.add_argument("-nk", "--new-kernel", required=False,
   help="new kernel")
args = vars(ap.parse_args())

input_full_path = os.path.abspath(args['img_path'])

project_full_path = os.path.abspath('..')

output_full_path = project_full_path + '/output/temp.txt'

kernel_full_path = project_full_path + '/processing/.kernel'

data_path = project_full_path + '/processing/data.s'

input_grayscale_path = project_full_path + "/output/img.txt"
height, width = image_handler.make_grayscale(input_full_path, input_grayscale_path)
buffer_size = 50000

with fileinput.FileInput(data_path, inplace=True) as file:
    for line in file:
        line = line.replace('$$INPUT$$', input_grayscale_path)
        line = line.replace('$$OUTPUT$$', output_full_path)
        line = line.replace('$$KERNEL$$', kernel_full_path)
        line = line.replace('$$WIDTH$$', str(width))
        line = line.replace('$$HEIGHT$$', str(height))
        line = line.replace('$$BUFFER_SIZE$$', str(buffer_size))
        print(line, end='')


kernel = args['kernel_id']
if kernel == '1' or kernel == None:
    kernel_handler.update_kernel([0,-1,0,-1,5,-1,0,-1,0])
elif kernel == '2':
    kernel_handler.update_kernel([-1,-1,-1,-1,8,-1,-1,-1,-1])
elif kernel == '3':
    kernel_handler.update_kernel([-1,-2,-1,0,0,0,1,2,1])
elif kernel == '4':
    kernel_handler.update_kernel([-2,-1,0,-1,1,1,0,1,2])
elif kernel == '5':
    kernel_handler.update_kernel([1,2,1,0,0,0,-1,-2,-1])

new_kernel = args['new_kernel']
if new_kernel != None:
    new_kernel = new_kernel.split(',')
    new_kernel = [int(i) for i in new_kernel]
    if len(new_kernel) == 9:
        kernel_handler.update_kernel(new_kernel)


os.system('touch ' + output_full_path)
os.system('riscv64-unknown-elf-as data.s filter.s io.s -o temp.o')
os.system('riscv64-unknown-elf-ld temp.o -o ../output/filter.out')
os.system('rm temp.o')
os.system('rv-jit ../output/filter.out')

if args['output'] == None:
    output_img_path = os.path.abspath("../output/filtered.png")
else:
    output_img_path = os.path.abspath(args['output'])

image_handler.display_image(output_full_path, width, output_img_path)

os.system('rm ../output/temp.txt')
os.system('rm ' + input_grayscale_path)

with fileinput.FileInput(data_path, inplace=True) as file:
    for line in file:
        line = line.replace(input_grayscale_path, '$$INPUT$$')
        line = line.replace(output_full_path, '$$OUTPUT$$')
        line = line.replace(kernel_full_path, '$$KERNEL$$')
        line = line.replace("WIDTH, " + str(width), 'WIDTH, $$WIDTH$$')
        line = line.replace("HEIGHT, " + str(height), 'HEIGHT, $$HEIGHT$$')
        line = line.replace("BUFFER_SIZE, " + str(buffer_size), 'BUFFER_SIZE, $$BUFFER_SIZE$$')
        print(line, end='')
