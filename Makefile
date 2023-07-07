BUILD_DIR=./build

DISK_IMG=$(BUILD_DIR)/disk.img
BOOTLOADER=$(BUILD_DIR)/boot.o
KERNEL=$(BUILD_DIR)/kernel.o

all: bootdisk

.PHONY: bootdisk bootloader qemu

bootloader:
	make -C bootloader

bootdisk: bootloader # build the boot disk
	dd if=/dev/zero of=$(DISK_IMG) bs=512 count=2880
	dd if=$(BOOTLOADER) of=$(DISK_IMG) bs=512 count=1 seek=0

qemu:
	qemu-system-x86_64 -machine q35 -fda $(BUILD_DIR)/disk.img

clean:
	rm $(BUILD_DIR)/*
