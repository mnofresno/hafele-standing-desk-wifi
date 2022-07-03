# Paths to Arduino IDE and cloned Arduino-Makefile
ARDUINO_DIR = $(HOME)/arduino
ARDMK_DIR = $(HOME)/Arduino-Makefile
# Specify the custom Gamebuino board and where it's installed
BOARD_TAG = gamebuino_meta_native
ALTERNATE_CORE_PATH = 

$(HOME)/.arduino15/packages/gamebuino/hardware/samd/1.2.1


# The Arduino libraries the game uses
ARDUINO_LIBS = Gamebuino_META SPI


# The META lib expects SKETCH_NAME to be defined
CFLAGS += -D__SKETCH_NAME__=&quot;$(TARGET).ino&quot;
CXXFLAGS += -D__SKETCH_NAME__=&quot;$(TARGET).ino&quot;


# Now that everything is configured, include Arduino-Makefile
include $(ARDMK_DIR)/Sam.mk