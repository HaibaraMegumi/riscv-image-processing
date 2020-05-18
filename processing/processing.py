from PIL import Image
import kernel_handler
import image_handler
import argparse
import numpy
import os


# Construct the argument parser
def initialize_argument_parser():
    ap = argparse.ArgumentParser(prefix_chars='@')

    # Add the arguments to the parser
    ap.add_argument("@i", "@@img-path", required=True)
    ap.add_argument("@k", "@@kernel-id", required=False)
    ap.add_argument("@o", "@@output", required=False)
    ap.add_argument("@nk", "@@new-kernel", required=False)
    return vars(ap.parse_args())


def restore_file(output, _input):
    with open(_input) as f:
        with open(output, "w") as f1:
            for line in f:
                f1.write(line)


def update_kernel(kernel, new_kernel):
    if new_kernel != '-1':
        try:
            new_kernel = new_kernel.split(',')
            new_kernel = [int(i) for i in new_kernel]
            if len(new_kernel) == 9:
                kernel_handler.update_kernel(new_kernel)
                print(" Using personalized kernel...")
        except:
            print(" Invalid kernel, using sharpening...")
            kernel_handler.update_kernel([0, -1, 0, -1, 5, -1, 0, -1, 0])
    elif kernel == '2':  # over sharpening
        print(" Using kernel for over-sharpening...")
        kernel_handler.update_kernel([-1, -2, -1, 2, 3, 2, -1, -2, -1])
    elif kernel == '3':  # blurring
        print(" Using kernel for blurring...")
        kernel_handler.update_kernel([1, -10, 1, -10, 1, -10, 1, -10, 1])
    elif kernel == '4':  # edge detection
        print(" Using kernel for edge detection...")
        kernel_handler.update_kernel([-1, -1, -1, -1, 8, -1, -1, -1, -1])
    elif kernel == '5':  # emboss
        print(" Using kernel for emboss...")
        kernel_handler.update_kernel([-2, -1, 0, -1, 1, 1, 0, 1, 2])
    elif kernel == '6':  # bottom sobel
        print(" Using kernel for bottom sobel...")
        kernel_handler.update_kernel([-1, -2, -1, 0, 0, 0, 1, 2, 1])
    elif kernel == '7':  # top sobel
        print(" Using kernel for top sobel...")
        kernel_handler.update_kernel([1, 2, 1, 0, 0, 0, -1, -2, -1])
    else:  # sharpening
        print(" Using kernel for sharpening...")
        kernel_handler.update_kernel([0, -1, 0, -1, 5, -1, 0, -1, 0])


def script():
    args = initialize_argument_parser()

    # All paths are absolute
    project_full_path = os.path.abspath('..')
    input_image_path = os.path.abspath(args['img_path'])
    raw_grayscale_filtered_path = './raw_filtered'
    raw_grayscale_unfiltered_path = "./raw_unfiltered"

    # Make input image grayscale
    height, width = image_handler.make_grayscale(input_image_path, raw_grayscale_unfiltered_path)
    if height == 0:
        print(" Exiting due to previous errors")
        return

    kernel = args['kernel_id']
    new_kernel = args['new_kernel']
    print(new_kernel)

    update_kernel(kernel, new_kernel)

    try:
        os.system('touch ' + raw_grayscale_filtered_path)
        print(" Running simulation...")
        os.system('../rv8/build/linux_x86_64/bin/rv-jit ../output/filter.out')
        print(" Cleaning up...")
    except:
        print(" Error")

    input_img_path = os.path.abspath("../output/unfiltered.png")
    if args['output'] == '-1':
        output_img_path = os.path.abspath("../output/filtered.png")
    else:
        output_img_path = os.path.abspath(args['output'])

    try:
        print(" Displaying image...")
        image_handler.display_image(raw_grayscale_filtered_path, width, output_img_path)
        image_handler.display_image(raw_grayscale_unfiltered_path, width, input_img_path, True)
        print(" Waiting for image...")
        filtered = Image.open(output_img_path)
        filtered.thumbnail((960, 1080), Image.ANTIALIAS)
        unfiltered = Image.open(input_img_path)
        unfiltered.thumbnail((960, 1080), Image.ANTIALIAS)
        merged = Image.fromarray(numpy.hstack((numpy.array(unfiltered), numpy.array(filtered))))
        merged.show()
    except:
        print(" Visualization error")

    print(" Cleaning up...")
    os.system('rm ' + raw_grayscale_filtered_path)
    os.system('rm ' + raw_grayscale_unfiltered_path)
    print(" Done")


script()
