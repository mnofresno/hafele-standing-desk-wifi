#ifndef ButtonsHandler_h
#define ButtonsHandler_h

#include <Arduino.h>

#define CLICK_DEBOUNCE_TIME 100
#define STATE_DEBOUNCE_TIME 200

#define STATE_CHANGE 1
#define ENTER_BUTTON_CLICK 2
#define BACK_BUTTON_CLICK 3

class ButtonsHandler {
    private:
        uint8_t _enter_button_pin;
        uint8_t _back_button_pin;
        uint8_t _invert_enter_button;
        uint8_t _invert_back_button;
        bool _last_button_state_for[2];
        unsigned long _last_millis_time_for[3];
        bool _state_has_changed_recently;
        int expected_level_for(bool inverted_button);
        bool do_read_button(uint8_t pin_number, bool invert);
        bool do_read_enter_button();
        bool do_read_back_button();
        bool debounce_state_change(int button_index, bool button_reading);
    public:
        ButtonsHandler(
            uint8_t enter_button_pin,
            uint8_t back_button_pin,
            bool invert_enter_button = false,
            bool invert_back_button = false
        );
        bool readEnterButton();
        bool readBackButton();
        void process(bool has_changed_state);
        String serialize_buttons_debug();
};
#endif
