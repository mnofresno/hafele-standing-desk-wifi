#!/bin/bash

cd "$(dirname "$0")"

docker build . -t ghcr.io/mnofresno/arduino-esp32-build:1.0.1
