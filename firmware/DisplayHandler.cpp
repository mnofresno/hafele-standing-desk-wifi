#include "DisplayHandler.h"

DisplayHandler::DisplayHandler(Adafruit_SSD1306 *display) {
    _display = display;
    _is_off = false;
}

void DisplayHandler::show_message(String input, bool reset_cursor) {
    if (_is_off) {
        return;
    }
    if (reset_cursor) {
        _display->setCursor(0, 0);
    }
    _display->setTextColor(SSD1306_WHITE, SSD1306_BLACK);
    _display->println(input);
    _display->display();
}

void DisplayHandler::println_with_pad(String input, int length) {
    _display->println(pad_string(input, " ", length));
}

void DisplayHandler::print_with_pad(String input, int length) {
    _display->print(pad_string(input, " ", length));
}

String DisplayHandler::pad_string(String input, String cPadWith, const unsigned char cMaxLen) {
    String strTemp = input;
    while (strTemp.length() < cMaxLen)
        strTemp += cPadWith;
    return strTemp;
}

void DisplayHandler::draw_starting(String version_string) {
    initialize();

    _display->clearDisplay();
    _display->setTextSize(FW_TEXT_SIZE_LARGE);

    _display->setTextColor(SSD1306_WHITE, SSD1306_BLACK);        // Draw white text on black background
    _display->setCursor(0,0);             // Start at top-left corner
    _display->println(F("WIFI"));
    _display->println(F("STANDING"));
    _display->println(F("DESK"));
    _display->setTextSize(FW_TEXT_SIZE_SMALL);
    _display->println(pad_string("", "-", 20));
    _display->println(version_string);
    _display->setTextSize(FW_TEXT_SIZE_LARGE);

    _display->display();
    delay(1000);
    _display->clearDisplay();
    _display->display();
}

void DisplayHandler::initialize() {
    delay(100);
    Wire.setClock(100000);
    Wire.setTimeOut(250);
    bool initialized = false;
    for (int retry = 0; retry < 5; retry++) {
        if (_display->begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
            initialized = true;
            break;
        }
        Serial.println(F("SSD1306 init attempt failed, retrying..."));
        delay(100);
    }

    if (!initialized) {
        Serial.println(F("SSD1306 initialization failed after retries"));
        return;
    }

    _is_off = false;
    _display->dim(false);
    _display->setTextColor(SSD1306_WHITE, SSD1306_BLACK);
    _display->clearDisplay();
    _display->display();
    delay(200);
}

Adafruit_SSD1306 * DisplayHandler::display() {
    return _display;
}

void DisplayHandler::print_full_screen_with_title(String title, String body) {
    if (_is_off) {
        return;
    }

    _display->clearDisplay();
    _display->setTextColor(SSD1306_WHITE, SSD1306_BLACK);
    _display->setCursor(0, 0);

    _display->setTextSize(FW_TEXT_SIZE_LARGE);
    _display->println(title);
    _display->setTextSize(FW_TEXT_SIZE_SMALL);
    _display->println(body);
    _display->display();
}

void DisplayHandler::anti_flickering(std::function<void()> callback, int millis_between_calls) {
    if (_is_off) {
        return;
    }
    unsigned long current_millis = millis();
    static unsigned long last_time_update = current_millis;
    if (current_millis - last_time_update > millis_between_calls) {
        callback();
        last_time_update = current_millis;
    }
}

void DisplayHandler::turn_off() {
    if (!_is_off) {
        _display->ssd1306_command(SSD1306_DISPLAYOFF);
        _is_off = true;
    }
}

void DisplayHandler::turn_on() {
    if (_is_off) {
        _is_off = false;
        _display->ssd1306_command(SSD1306_CHARGEPUMP);
        _display->ssd1306_command(0x14);
        _display->ssd1306_command(SSD1306_MEMORYMODE);
        _display->ssd1306_command(0x00);
        _display->ssd1306_command(SSD1306_SETSTARTLINE | 0x00);
        _display->ssd1306_command(SSD1306_DISPLAYON);
        _display->display();
    }
}

bool DisplayHandler::is_off() const {
    return _is_off;
}

void DisplayHandler::recover_i2c_bus() {
    Wire.end();
    pinMode(I2C_SDA_PIN, INPUT_PULLUP);
    pinMode(I2C_SCL_PIN, OUTPUT);
    digitalWrite(I2C_SCL_PIN, HIGH);
    delayMicroseconds(10);
    for (int i = 0; i < 9; i++) {
        digitalWrite(I2C_SCL_PIN, LOW);
        delayMicroseconds(10);
        digitalWrite(I2C_SCL_PIN, HIGH);
        delayMicroseconds(10);
    }
    // STOP condition: SDA LOW -> SCL HIGH -> SDA HIGH
    pinMode(I2C_SDA_PIN, OUTPUT);
    digitalWrite(I2C_SDA_PIN, LOW);
    delayMicroseconds(10);
    digitalWrite(I2C_SCL_PIN, HIGH);
    delayMicroseconds(10);
    digitalWrite(I2C_SDA_PIN, HIGH);
    delayMicroseconds(10);

    Wire.begin(I2C_SDA_PIN, I2C_SCL_PIN);
    Wire.setClock(100000);
    Wire.setTimeOut(250);
}

void DisplayHandler::reinitialize() {
    recover_i2c_bus();
    initialize();
}
