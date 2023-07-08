BUILD_DIR = ../build
KERNEL_SRC = ./src/kernel.asm
KERNEL_OBJ := $(BUILD_DIR)/kernel.o

all: $(KERNEL_SRC)
	nasm -f bin $(KERNEL_SRC) -o $(KERNEL_OBJ)
