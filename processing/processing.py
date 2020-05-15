import kernel_handler
import image_handler
import argparse
import cv2
import os


# Construct the argument parser
def initialize_argument_parser():
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
    return vars(ap.parse_args())


def restore_file(output, _input):
    with open(_input) as f:
        with open(output, "w") as f1:
            for line in f:
                f1.write(line)


def update_kernel(kernel, new_kernel):
    if kernel == '2':  # over sharpening
        print("Using kernel for over-sharpening...")
        kernel_handler.update_kernel([0, -6, 0, -6, 6, -6, 0, -6, 0])
    elif kernel == '3':  # blurring
        print("Using kernel for blurring...")
        kernel_handler.update_kernel([1, -10, 1, -10, 1, -10, 1, -10, 1])
    elif kernel == '4':  # edge detection
        print("Using kernel for edge detection...")
        kernel_handler.update_kernel([-1, -1, -1, -1, 8, -1, -1, -1, -1])
    elif kernel == '5':  # emboss
        print("Using kernel for emboss...")
        kernel_handler.update_kernel([-2, -1, 0, -1, 1, 1, 0, 1, 2])
    elif kernel == '6':  # bottom sobel
        print("Using kernel for bottom sobel...")
        kernel_handler.update_kernel([-1, -2, -1, 0, 0, 0, 1, 2, 1])
    elif kernel == '7':  # top sobel
        print("Using kernel for top sobel...")
        kernel_handler.update_kernel([1, 2, 1, 0, 0, 0, -1, -2, -1])
    else:  # sharpening
        print("Using kernel for sharpening...")
        kernel_handler.update_kernel([0, -1, 0, -1, 5, -1, 0, -1, 0])

    if new_kernel is not None:
        try:
            new_kernel = new_kernel.split(',')
            new_kernel = [int(i) for i in new_kernel]
            if len(new_kernel) == 9:
                kernel_handler.update_kernel(new_kernel)
        except:
            print("Invalid kernel, using sharpening...")
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
        print("Exiting due to previous errors")
        return

    kernel = args['kernel_id']
    new_kernel = args['new_kernel']

    update_kernel(kernel, new_kernel)

    try:
        os.system('touch ' + raw_grayscale_filtered_path)
        print("Running simulation...")
        os.system('../rv8/build/linux_x86_64/bin/rv-jit ../output/filter.out')
        print("Cleaning up...")
    except:
        print("Error")

    input_img_path = os.path.abspath("../output/unfiltered.png")
    if args['output'] is None:
        output_img_path = os.path.abspath("../output/filtered.png")
    else:
        output_img_path = os.path.abspath(args['output'])

    try:
        print("Displaying image...")
        image_handler.display_image(raw_grayscale_filtered_path, width, output_img_path, "Filtered image")
        image_handler.display_image(raw_grayscale_unfiltered_path, width, input_img_path, "Unfiltered image", True)
        print("Waiting for image...")
        cv2.waitKey(0)
        cv2.destroyAllWindows()
    except Exception:
        print(Exception)
        print("Visualization error")

    print("Cleaning up...")
    os.system('rm ' + raw_grayscale_filtered_path)
    os.system('rm ' + raw_grayscale_unfiltered_path)
    print("Done")


script()
