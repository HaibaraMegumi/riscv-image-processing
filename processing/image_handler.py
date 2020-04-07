import cv2
import numpy

def make_grayscale(img_path, new_path):

    #read input image
    gray_img = cv2.imread(img_path, 0)
    rows,cols = gray_img.shape
    #create output image
    new_img = open(new_path, 'wb')
    #write new content
    cont = 0
    for i in range(rows):
        for j in range(cols):
            new_img.write(bytes([gray_img[i,j]]))

    #close file
    new_img.close()
    return rows,cols


def display_image(img_path, columns, new_path):
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
    sharp_img = cv2.resize(sharp_img, (600,600))
    win_name = "processed image"
    cv2.namedWindow(win_name)        # Create a named window
    cv2.moveWindow(win_name, 40,30)  # Move it to (40,30)
    cv2.imwrite(new_path, sharp_img)
    cv2.imshow(win_name, sharp_img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
