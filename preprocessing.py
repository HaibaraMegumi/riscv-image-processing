import cv2
import numpy

def read_grayscale(img_path, new_path):

    #read input image
    gray_img = cv2.imread(img_path, 0)
    rows,cols = gray_img.shape
    print(rows, cols, rows*cols)
    #create output image
    new_img = open(new_path, 'wb')

    #write new content
    cont = 0
    for i in range(rows):
        for j in range(cols):
            new_img.write(bytes([gray_img[i,j]]))

    #close file
    new_img.close()


read_grayscale("/home/mherrera/Downloads/mushroom.png","testImg.txt")

def read_sharpened(img_path, columns):
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
    sharp_img = numpy.array(sharp_img, dtype=numpy.uint8)
    sharp_img = cv2.resize(sharp_img, (600,600))
    cv2.imshow("window", sharp_img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

def write_test(img_path, input_bytes):
    with open(img_path, "wb") as img:
        for byte in input_bytes:
            img.write(byte.to_bytes(1, byteorder='big', signed=False))

# write_test('testImg.txt', [206, 205, 247, 244, 161, 137, 192, 154, 75])
# write_test('testImg.txt', [1,2,3,4,5,6,7,8,9])
# read_sharpened('testImg.txt', 3)
