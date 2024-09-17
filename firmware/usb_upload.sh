#!/bin/bash
cd $(dirname "$0")

source ./docker-build/build.env

USB_PORT=${1:-USB0}

arduinocli() {
    docker run --device="/dev/tty$USB_PORT" \
        --rm -v `pwd`:/firmware -t $IMAGE_NAME arduino-cli "$@"
}

arduinocli upload -p "/dev/tty$USB_PORT" --fqbn esp32:esp32:esp32 -i /firmware/build/firmware.ino.bin
