#!/bin/bash

curl -vvvv -F upload=@build/firmware.ino.bin "http://$1/u"
