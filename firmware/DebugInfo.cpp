#include "DebugInfo.h"
#include <Adafruit_SSD1306.h>

DebugInfo::DebugInfo(
    DisplayHandler *display_handler,
    ButtonsHandler *buttons_handler
) {
    _display_handler = display_handler;
    _buttons_handler = buttons_handler;
}

void DebugInfo::print() {
    if (_enabled) {
        _display_handler->anti_flickering([&]() {
            Adafruit_SSD1306 *_display = _display_handler->display();
            _display->setCursor(50,45);
            _display->setTextSize(1);
            _display->println(_buttons_handler->serialize_buttons_debug());
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
