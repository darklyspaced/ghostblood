BUILD_DIR = ../build
BOOTLOADER_SRC = ./src/boot.asm
BOOTLOADER_OBJ := $(BUILD_DIR)/boot.o

all: $(BOOTLOADER_SRC)
	nasm -f bin $(BOOTLOADER_SRC) -o $(BOOTLOADER_OBJ)
