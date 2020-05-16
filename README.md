# Sharpening y Over-Sharpening
Desarrollo en ensamblador (asm) de un programa para procesar el sharpening y oversharpening de una imagen mediante convolucion con mascaras de 3x3.

## Ambiente de Desarrollo
RISC-V

### Prerequisitos
```bash
sudo apt install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev \
                 gawk build-essential bison flex texinfo gperf libtool patchutils bc \
                 zlib1g-dev libexpat-dev git
```
### Instalar toolchain
gcc
```bash
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
git submodule update --init --recursive

# pick an install path, e.g. /opt/riscv64
./configure --prefix=/opt/riscv64
make
```

### Instalar emulador
RV8
```bash
git clone https://github.com/rv8-io/rv8.git
cd rv8
git submodule update --init --recursive

make
sudo make install
```
## Llamadas del sistema
syscall riscv y x86 para compara

| Architecture | Instruction | System Call # | Return Value | Return Value 2 | Error |
|--------------|-------------|---------------|--------------|----------------|-------|
| riscv        | ecall       | a7            | a0           | a1             | -     |
| x86-64       | syscall     | rax           | rax          | rdx            | -     |


argumentos

| Architecture | arg1 | arg2 | arg3 | arg4 | arg5 | arg6 | arg7 |
|--------------|------|------|------|------|------|------|------|
| riscv        | a0   | a1   | a2   | a3   | a4   | a5   | -    |
| x86-64       | rdi  | rsi  | rdx  | r10  | r8   | r9   | -    |

- getcwd: **17**
getcwd(char \*buf, size_t size) copies an absolute pathname of the current working directory to the array pointed to by buf, which is of length size.

- openat: **56**

- close: **57**
close(int fd) closes a file descriptor, so that it no longer refers to any file and may be reused. returns zero on success

- lseek: **62**
lseek(int fd, off_t offset, int whence) repositions the file offset of the open file description associated with the file descriptor fd to the argument offset

- read: **63**
 read(int fd, void \*buf, size_t count) attempts to read up to count bytes from file descriptor fd into the buffer starting at buf.
 On files that support seeking, the read operation commences at the file offset, and the file offset is incremented by the number of bytes read.

- write: **64**
write(int fd, const void \*buf, size_t count) writes up to count bytes from the buffer starting at buf to the file referred to by the file descriptor fd.

pread, pwrite

- exit: **93**
terminates the calling process "immediately"

- open: **1024**
open(const char \*pathname, int flags)
The open() system call opens the file specified by pathname.

## Uso

### Ensamble
  ```
  riscv64-unknown-elf-as <input> -o <output>
  ```

### Linker
  ```
  riscv64-unknown-elf-ld <input> -o <output>
  ```

### Ejecuci'on
  ```
  rv-jit <input>
  ```
### Depuraci'on
```
  rv-sim <--log-operands> <--log-instructions> <executable>
```

Los flags de openat son con Or, por ejemplo, ReadWrite es 2 (01) y Append es 1024(10000000000) entonces el flag es Or de ellos 1026

lseek whence1_

```
#define SEEK_SET    0   /* set file offset to offset */
#define SEEK_CUR    1   /* set file offset to current plus offset */
#define SEEK_END    2   /* set file offset to EOF plus offset */
```

alternativa mmap para cargar a memoria


```sudo apt install python3-pip```

```pip3 install opencv-python```


using atom with language-riscv package


no se pueden hacer varios jal seguidos hay que guardar el ra

sharpening
0 -1 0
-1 5 -1
0 -1 0


riscv64-unknown-elf-as sharpen.s data.s io.s -o ../Output/sharp.o

riscv64-unknown-elf-ld ../Output/sharp.o -o ../Output/sharp.out

rv-jit  ../Output/sharp.out


pip3 install matplotlib

git clone sharpening
cd sharpening
git submodule update --init --recursive
cd rv8
make


chmod +x install.sh
