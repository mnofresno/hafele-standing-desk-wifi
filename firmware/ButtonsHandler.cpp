#include "ButtonsHandler.h"

#define CLICK_DEBOUNCE_TIME 250
#define STATE_DEBOUNCE_TIME 250

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
    bool button_reading = do_read_button(_enter_button_pin, _invert_enter_button);

    return debounce_state_change(button_reading);
}

bool ButtonsHandler::readBackButton() {
    bool button_reading = do_read_button(_back_button_pin, _invert_back_button);

    return debounce_state_change(button_reading);
}

bool ButtonsHandler::debounce_state_change(bool button_reading) {
    // static bool last_button_reading = button_reading;
    // unsigned long current_millis = millis();
    // static unsigned long last_millis = current_millis;

    // if (last_button_reading != button_reading) {
    //     last_millis = current_millis;
    // }

    // last_button_reading = button_reading;

    // if (((current_millis - last_millis) > CLICK_DEBOUNCE_TIME)) {
    //     return button_reading && !_state_has_changed_recently;
    // }

    // return false;

    return button_reading && !_state_has_changed_recently;
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

bool ButtonsHandler::do_read_button(uint8_t pin_number, bool invert) {
    return digitalRead(pin_number) == expected_level_for(invert);
}

// void ButtonsHandler::process(bool has_changed_state) {
//     if (has_changed_state) {
//         _last_state_change = millis();
//     }
// }

void ButtonsHandler::process(bool has_changed_state) {
    if (has_changed_state) {
        _last_state_change = millis();
        _state_has_changed_recently = true;
    } else {
        if (millis() - _last_state_change > STATE_DEBOUNCE_TIME) {
            _state_has_changed_recently = false;
        }
    }
}
