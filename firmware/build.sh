#!/bin/bash

set -eu

cd "$(dirname "$0")"

source ./docker-build/build.env

arduinocli() {
    docker run --rm -v `pwd`:/firmware  -t $IMAGE_NAME arduino-cli "$@"
}

arduinocli compile --fqbn esp32:esp32:esp32 . --build-path ./build --verbose

# Run native unit tests in the same reproducible Docker image.
docker run --rm -v `pwd`:/firmware -t $IMAGE_NAME bash -c \
    'cd /firmware && g++ -I. -Itests -std=c++11 tests/ButtonsHandler_test.cpp ButtonsHandler.cpp -o /tmp/test_buttons && /tmp/test_buttons'
