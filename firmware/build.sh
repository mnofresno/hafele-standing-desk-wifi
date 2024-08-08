#!/bin/bash

set -eu

cd "$(dirname "$0")"

IMAGE_NAME="ghcr.io/mnofresno/arduino-esp32-build:1.0.0"

arduinocli() {
    docker run --rm -v `pwd`:/firmware  -t $IMAGE_NAME arduino-cli "$@"
}

arduinocli compile --fqbn esp32:esp32:esp32 . --build-path ./build --verbose
