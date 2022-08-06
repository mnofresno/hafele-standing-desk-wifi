#include "ButtonsHandler.h"

ButtonsHandler::ButtonsHandler(
    uint8_t enter_button_pin,
    uint8_t back_button_pin,
    bool invert_enter_button,
    bool invert_back_button
) {
    _enter_button_pin = enter_button_pin;
    _back_button_pin = back_button_pin;
    _invert_enter_button = invert_enter_button;
    _invert_back_button = invert_back_button;
    pinMode(_back_button_pin, INPUT);
    pinMode(_enter_button_pin, INPUT);
}

bool ButtonsHandler::readEnterButton() {
    return digitalRead(_enter_button_pin) == expected_level_for(_invert_enter_button);
}

bool ButtonsHandler::readBackButton() {
    return digitalRead(_back_button_pin) == expected_level_for(_invert_back_button);
}

String ButtonsHandler::serialize_buttons_debug() {
    return "B: " + String(readBackButton())
        + " E: " + String(readEnterButton());
}

int ButtonsHandler::expected_level_for(bool inverted_button) {
    return inverted_button
        ? LOW
        : HIGH;
}
