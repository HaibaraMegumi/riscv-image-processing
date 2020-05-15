kernel_path = "./.kernel"


def update_kernel(kernel):
    with open(kernel_path, "wb") as kernel_file:
        for byte in kernel:
            if byte < 0 or byte > 255:
                byte = 255
            kernel_file.write(bytes([byte]))
