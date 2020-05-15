import cv2
import numpy


def make_grayscale(img_path, new_path):
    print("Converting image to raw grayscale format...")

    # read input image
    print("Opening image at %s..." % img_path)
    gray_img = cv2.imread(img_path, 0)
    if gray_img is None:
        print("Error opening image at %s" % img_path)
        return 0, 0

    print("Getting image dimensions...")
    rows, cols = gray_img.shape
    print("%d, %d" % (rows, cols))

    # create output image
    print("Storing grayscale image at %s..." % new_path)
    new_img = open(new_path, 'wb')
    if new_img is None:
        print("Error opening image at %s" % new_path)
        return 0, 0
    print("Writing image...")
    # write new content
    cont = 0
    for i in range(rows):
        for j in range(cols):
            new_img.write(bytes([gray_img[i, j]]))

    # close file
    print("Closing image...")
    new_img.close()
    print("Image converted successfully")
    return rows, cols


def display_image(img_path, columns, new_path, name):
    sharp_img = []
    row = []
    col = 0
    with open(img_path, "rb") as img:
        byte = img.read(1)
        while byte != b"":
            if col == columns:
                col = 0
                sharp_img.append(row)
                row = []
            row.append(int.from_bytes(byte, byteorder='big'))
            col += 1
            byte = img.read(1)
        sharp_img.append(row)
    sharp_img = numpy.matrix(sharp_img, dtype=numpy.uint8)
    # sharp_img = cv2.resize(sharp_img, (600,600))
    win_name = name
    cv2.namedWindow(win_name, cv2.WINDOW_NORMAL)  # Create a named window
    cv2.moveWindow(win_name, 40, 30)  # Move it to (40,30)
    cv2.imwrite(new_path, sharp_img)
    cv2.imshow(win_name, sharp_img)
