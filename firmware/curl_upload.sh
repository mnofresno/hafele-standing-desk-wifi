#!/bin/bash

cd "$(dirname "$0")"

curl -vvvv -F upload=@build/firmware.ino.bin "http://$1/u"
