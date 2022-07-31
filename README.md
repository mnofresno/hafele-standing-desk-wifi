# Hafele Standing Desk

## A WiFi-control modification

### Overview

This project explains the steps done to modify a Hafele &reg; Standing Desk

## Table of contents

### Materials

* Printing fillament:
  * About 52 grams and 17.46 meters for the case
  * About XX grams and YY meters for the lid of the case
* CPU: Wemos D1 ESP32, 160~240 Mhz, 320 KiB RAM
* Display: OLED 128x64 px i2C SSD1306, viewable area: 14.7x26.7 mm
* Relay module shield 2 CH

### Software

* The firmware was developed in Arduino C++, based on [WiFi Manager platform](https://github.com/tzapu/WiFiManager)
* The case was parametrically-designed using FreeCAD 0.0.19, the available parameters are:
  * Length
  * Height
  * Width
  * Width and height of display
  * Radius of curvature
  * Angle of the panel
  * Thickness of the walls
  * Display, x and y position
  * Distance between buttons
  * Thickness of the lid
  * Diameter length and separation of bolts
  * Inner diameter of bolt nuts

### Firmware Compilation & Deploy

Install arduino CLI with: curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh

And Arduino makefile with sudo apt install arduino-mk

Then to compile the source code use this commands:

```bash
cd firmware
arduino-cli compile --fqbn esp32:esp32:esp32 . --build-path ./build

```

And to upload the file use the following:

```bash
arduino-cli upload -p /dev/ttyUSB0 --fqbn esp32:esp32:esp32 . --build-path ./build
```

### Contribuiting

Please send e-mail to the owner of this repo
