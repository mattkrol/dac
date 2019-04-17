# BARE METAL C MAKEFILE FOR STM32F4
# Written by Matt Krol

# Directory Structure
OBJ_DIR = obj
SRC_DIR = src
INC_DIR = inc
BIN_DIR = bin

# Final Executable Name
TARGET = runme

# Define File Variables
SOURCES := $(wildcard $(SRC_DIR)/*)
OBJECTS := $(patsubst $(SRC_DIR)%.c, $(OBJ_DIR)%.o, $(SOURCES))
OBJECTS := $(patsubst $(SRC_DIR)%.s, $(OBJ_DIR)%.o, $(OBJECTS))

# Linker Script Location
LD_SCRIPT = STM32F407VGTx_FLASH.ld

# Define Toolchain Variables
CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
STFLASH = st-flash

# Flash Start Address
FLASH_ADDR = 0x08000000

# Compile and Link Flags
CFLAGS = -g -Wall -I$(INC_DIR)
LDFLAGS = -Wl,-Map=$(OBJ_DIR)/$(TARGET).map,-T$(LD_SCRIPT),-lnosys,-lm,-lc,-lgcc
CPU = -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16

# Implicit Rules
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@$(CC) $(CPU) $(CFLAGS) -c -o $@ $^
	@echo "$^ => $@"

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s
	@$(CC) $(CPU) $(CFLAGS) -c -o $@ $^
	@echo "$^ => $@"

# Regular Rules
all: $(OBJ_DIR) $(BIN_DIR) $(BIN_DIR)/$(TARGET).bin $(BIN_DIR)/$(TARGET).elf

$(BIN_DIR)/$(TARGET).bin: $(BIN_DIR)/$(TARGET).elf
	@$(OBJCOPY) -O binary $^ $@
	@echo "$^ => $@"

$(BIN_DIR)/$(TARGET).elf: $(OBJECTS)
	@$(CC) $(CPU) -o $@ $^ $(LDFLAGS)
	@echo "$^ => $@"

$(BIN_DIR):
	@mkdir $(BIN_DIR)

$(OBJ_DIR):
	@mkdir $(OBJ_DIR)

flash: all
	@$(STFLASH) write $(BIN_DIR)/$(TARGET).bin $(FLASH_ADDR)

# Phony Rules
.PHONY: clean
clean:
	@rm -f $(OBJECTS)
	@rm -f $(BIN_DIR)/$(TARGET).elf
	@rm -f $(BIN_DIR)/$(TARGET).bin
	@rm -f $(OBJ_DIR)/$(TARGET).map

# EOF
