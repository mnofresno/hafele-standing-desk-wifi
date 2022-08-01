#!/bin/bash
arduino-cli upload -p /dev/ttyUSB0 --fqbn esp32:esp32:esp32 -i build/firmware.ino.bin
