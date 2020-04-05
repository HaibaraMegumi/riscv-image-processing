import cv2

def read_grayscale(img_path, new_path):

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

# cv2.imshow("window",gray_img)
# cv2.waitKey(0)
# cv2.destroyAllWindows()
#gray_img = cv2.resize(gray_img, (100,100))

read_grayscale("/home/mherrera/Downloads/mushroom.png","../../../Downloads/mushroom.txt")
