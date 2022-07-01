# Hafele Standing Desk

## A WiFi-control modification

### Overview

This project explains the steps done to modify a Hafele &reg; Standing Desk

## Table of contents

[[_TOC_]]

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

### Contribuiting

Please send e-mail to the owner of this repo