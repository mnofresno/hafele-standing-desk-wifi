#!/bin/bash
arduino-cli upload -p /dev/ttyUSB2 --fqbn esp32:esp32:esp32 -i build/firmware.ino.bin
