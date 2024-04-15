#!/bin/bash
cd "$(dirname "$0")"

arduino-cli compile --fqbn esp32:esp32:esp32 . --build-path ./build
