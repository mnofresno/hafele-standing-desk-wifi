#include "DebugInfo.h"
#include <Adafruit_SSD1306.h>

DebugInfo::DebugInfo(
    DisplayHandler *display_handler,
    uint8_t enter_button_pin,
    uint8_t back_button_pin
) {
    _display_handler = display_handler;
    _enter_button_pin = enter_button_pin;
    _back_button_pin = back_button_pin;
}

void DebugInfo::print() {
    if (_enabled) {
        _display_handler->anti_flickering([&]() {
            Adafruit_SSD1306 *_display = _display_handler->display();
            _display->setCursor(50,45);
            _display->setTextSize(1);
            _display->println(
                "B: " + String(digitalRead(_back_button_pin))
                + " E: " + String(!digitalRead(_enter_button_pin))
            );
            _display->setCursor(50,55);
            _display->println(
                "S: " + String(_storing_config)
                + " F: " + String(_fetching_config)
            );
            _display->display();
            _display->setTextSize(2);
        });
    }
}

void DebugInfo::clear() {
    _display_handler->anti_flickering([&]() {
        Adafruit_SSD1306 *_display = _display_handler->display();
        _display->setTextSize(FW_TEXT_SIZE_SMALL);
        _display->setCursor(50,45);
        _display_handler->println_with_pad("", 10);
        _display->setCursor(50,55);
        _display_handler->println_with_pad("", 10);
        _display->display();
        _display->setTextSize(FW_TEXT_SIZE_LARGE);
    });
}

void DebugInfo::showConfig(int64_t dial_position) {
    _display_handler->show_message("Dbg: " + String(_enabled ? "ON ": "OFF"));
    if (last_dial_position != dial_position) {
        _enabled = !_enabled;
        last_dial_position = dial_position;
    }
    if (!_enabled) {
        clear();
    }
}

void DebugInfo::setFetching(bool fetching) {
    _fetching_config = fetching;
}

void DebugInfo::setStoring(bool storing) {
    _storing_config = storing;
}
