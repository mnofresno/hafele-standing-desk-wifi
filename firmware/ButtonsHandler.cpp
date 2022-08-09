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
    bool button_reading = do_read_enter_button();

    return debounce_state_change(ENTER_BUTTON_CLICK, button_reading);
}

bool ButtonsHandler::readBackButton() {
    bool button_reading = do_read_back_button()

    return debounce_state_change(BACK_BUTTON_CLICK, button_reading);
}

bool ButtonsHandler::debounce_state_change(int button_index, bool button_reading) {
    unsigned long current_millis = millis();

    if (_last_button_state_for[button_index] != button_reading) {
        _last_millis_time_for[button_index] = current_millis;
    }

    _last_button_state_for[button_index]  = button_reading;

    if (((current_millis - _last_millis_time_for[button_index]) > CLICK_DEBOUNCE_TIME)) {
        return button_reading && !_state_has_changed_recently;
    }

    return false;
}

String ButtonsHandler::serialize_buttons_debug() {
    return "B: " + String(do_read_back_button())
        + " E: " + String(do_read_enter_button());
}

int ButtonsHandler::expected_level_for(bool inverted_button) {
    return inverted_button
        ? LOW
        : HIGH;
}

bool ButtonsHandler::do_read_enter_button() {
    return do_read_button(_enter_button_pin, _invert_enter_button);
}

bool ButtonsHandler::do_read_back_button() {
    return do_read_button(_back_button_pin, _invert_back_button);
}

bool ButtonsHandler::do_read_button(uint8_t pin_number, bool invert) {
    return digitalRead(pin_number) == expected_level_for(invert);
}

void ButtonsHandler::process(bool has_changed_state) {
    if (has_changed_state) {
        _last_millis_time_for[STATE_CHANGE] = millis();
        _state_has_changed_recently = true;
    } else {
        if (millis() - _last_millis_time_for[STATE_CHANGE] > STATE_DEBOUNCE_TIME) {
            _state_has_changed_recently = false;
        }
    }
}
