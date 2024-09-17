#!/bin/bash

cd "$(dirname "$0")"

source ./build.env

docker build . -t "$IMAGE_NAME"
docker push "$IMAGE_NAME"
