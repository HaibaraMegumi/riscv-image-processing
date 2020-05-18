# RISCV Image Processing

This project achieves basic image filtering by applying 3x3 kernels to it. It produces a 
grayscale output for simplicity but it can be extended by applying the kernel to the RGB 
representation. 

The image preprocessing is handled by Python, it produces a raw representation of the image
by writing each pixel in its byte representation into a file that will later be accessed.
The process of displaying the image is also handled by python.
 
However, the image filtering was programmed in **_riscv assembly_**. It takes the raw bytes 
representation of the image and applies a 3x3 kernel to it, producing another raw binary file
as the filtered image.

All of the workflow is wrapped in two bash scripts one for installation and another one for 
filtering. 


## Dependencies
This project is expected to be run on Linux. It was tested in Ubuntu 18.04 as well as Ubuntu 20.04. 
 
As mentioned before this project requires python3 to handle image pre and post processing. It also 
requires git in order to clone the emulator form github.

The rest of the dependencies are handled **automatically** by the installation script that executes
the following commands.

```bash
# install pip3
apt install python3-pip

# install python packages
pip3 install opencv-python
pip3 install numpy
pip3 install argparse
pip3 install Pillow
```

##Installation
The installation and a quick demo of the project can be followed in the next [video](https://www.youtube.com/watch?v=4rwYiPecA10&t=3s).

Clone this repository into a directory where you have permissions `git clone https://github.com/m-herrera/riscv-image-processing`,
then move into the project by typing `cd riscv-image-processing`. 

Once in the same directory as the project initialize its submodules (the emulator) with the command
`git submodule update --init --recursive`. 
 
With the project cloned, the installation only requires the execution of the **install** script. Make sure the files has 
execution permissions; if not, add them using the command `chmod +x ./install`.

Run the installation script and give root permissions if prompted.
```bash
./install
```
##Use

The filtering is done by running the **filter** script with its arguments. If necessary type `./filter -h`
to see help function and possible arguments.

The input image is the only required argument, it is specified as follows. This assumes the desired filter is 
sharpening.
```bash
./filter -i <path to input file>
```

The other arguments are optional and let the user choose a predefined kernel `-k`, a new user
defined kernel `-n` and the output of the filtered image `-o` (path and file name). Paths can be 
absolute or relative. If no output file is specified the filtered image is stored in the output 
directory with the name **filtered.png**.
### Filtering examples

```bash
./filter -i <path to input file> -k 2
```
This is the list of predefined kernels.

- 1: sharpening (default)
- 2: over sharpening
- 3: blurring
- 4: edge detection
- 5: emboss
- 6: bottom sobel
- 7: top sobel

```bash
./filter -i <path to input file> -n 0,-1,0,-1,5,-1,0,-1,0
```
Avoid leaving spaces between commas.
```bash
./filter -i <path to input file> -k 3 -o <path to output file>
```
Remember its the path to the output file not the directory, the file will be created if it doesn't exist.

The output image has the unfiltered image on the left and the filtered image on the right. 

##Thanks

For further questions or comments please contact me at m.herrera0799@gmail.com.