FROM python:3.7-slim

RUN apt-get update && apt-get install -y curl
RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/usr/bin sh
RUN pip install pyserial
RUN arduino-cli core update-index
RUN arduino-cli core install esp32:esp32@2.0.8
RUN arduino-cli lib install WiFiManager@2.0.5-beta
RUN arduino-cli lib install "Adafruit BusIO@1.16.1"
RUN arduino-cli lib install "Adafruit GFX Library@1.11.10"
RUN arduino-cli lib install "Adafruit SSD1306@2.5.10"
RUN arduino-cli lib install ESP32Encoder@0.10.1
RUN arduino-cli lib install ArduinoJson@7.1.0
RUN arduino-cli lib install NTPClient@3.2.1

WORKDIR /firmware
CMD [ "arduino-cli" ]
