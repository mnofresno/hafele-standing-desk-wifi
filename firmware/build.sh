#!/bin/bash

set -eu

cd "$(dirname "$0")"

source ./docker-build/build.env

arduinocli() {
    docker run --rm -v `pwd`:/firmware  -t $IMAGE_NAME arduino-cli "$@"
}

arduinocli compile --fqbn esp32:esp32:esp32 . --build-path ./build --verbose
