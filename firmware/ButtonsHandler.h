#ifndef ButtonsHandler_h
#define ButtonsHandler_h

#include <Arduino.h>

class ButtonsHandler {
    private:
        uint8_t _enter_button_pin;
        uint8_t _back_button_pin;
        uint8_t _invert_enter_button;
        uint8_t _invert_back_button;
        int expected_level_for(bool inverted_button);
    public:
        ButtonsHandler(
            uint8_t enter_button_pin,
            uint8_t back_button_pin,
            bool invert_enter_button = false,
            bool invert_back_button = false
        );
        bool readEnterButton();
        bool readBackButton();
        String serialize_buttons_debug();
};
#endif
