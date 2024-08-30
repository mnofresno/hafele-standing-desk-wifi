#!/bin/bash

set -eu

if [ -z "$1" ]; then
    echo "Uso: $0 <IP_DEL_DISPOSITIVO>"
    echo "Por favor, proporciona la dirección IP del dispositivo."
    exit 1
fi

cd "$(dirname "$0")"

response=$(curl -s -F upload=@build/firmware.ino.bin "http://$1/u")
if echo "$response" | grep -q "Update Successful"; then
    echo "- upload ok"
else
    echo "- error"
fi
