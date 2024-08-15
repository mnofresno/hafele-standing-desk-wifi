#!/bin/bash
USB_PORT=${1:-USB0}
arduino-cli upload -p "/dev/tty$USB_PORT" --fqbn esp32:esp32:esp32 -i build/firmware.ino.bin
