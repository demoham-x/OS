ASM = nasm
SRC_DIR = source
BUILD_DIR = build
QEMU = qemu-system-x86_64  # Adjust based on the architecture you're emulating
QEMU_RUN_FLAGS = -fda
IMG_FILE = $(BUILD_DIR)/main_floopy.img
BIN_FILE = $(BUILD_DIR)/main.bin

# Suppress command echoing for the whole Makefile
#MAKEFLAGS += -s

# Ensure build directory exists
#$(BUILD_DIR):
#	@echo "Creating build directory if it doesn't exist..."
#	mkdir -p $(BUILD_DIR)

# Default target to assemble the binary and floppy image
all: $(IMG_FILE)

# Generate the floppy disk image from the binary
$(IMG_FILE): $(BIN_FILE) | $(BUILD_DIR)
	@echo "Creating floppy disk image $(IMG_FILE)..."
	cp $(BIN_FILE) $(IMG_FILE)
	# Create an empty 1440 KB floppy disk image and copy the binary to it
	@echo "Creating a 1.44 MB image file and copying the binary..."
	fsutil file createnew $(IMG_FILE) 1474560  # Create a 1.44 MB image file (1440 KB)
	copy /B $(BIN_FILE) + $(IMG_FILE) $(IMG_FILE)
	@echo "Floppy disk image created at $(IMG_FILE)."

# Generate the binary from the assembly code
$(BIN_FILE): $(SRC_DIR)/boot.asm | $(BUILD_DIR)
	@echo "Assembling $(SRC_DIR)/boot.asm to generate $(BIN_FILE)..."
	$(ASM) $(SRC_DIR)/boot.asm -f bin -o $(BIN_FILE)
	@echo "Binary file $(BIN_FILE) generated."

# Clean the build directory using `rm` (works in Git Bash, Cygwin, WSL, etc.)
clean:
	@echo "Cleaning $(BUILD_DIR)..."
	ls $(BUILD_DIR)  # List files in the build directory
	@echo "Removing all files in $(BUILD_DIR)..."
	rm -rf $(BUILD_DIR)/*
	@echo "Cleaned $(BUILD_DIR)."

# Run the floppy image with QEMU
run: $(IMG_FILE)
	@echo "Running the image $(IMG_FILE) with QEMU..."
#	$(QEMU) -drive file=$(IMG_FILE),format=raw,media=disk
	$(QEMU) $(QEMU_RUN_FLAGS) $(IMG_FILE)
	@echo "QEMU running $(IMG_FILE)."
