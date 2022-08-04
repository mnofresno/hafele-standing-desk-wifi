#ifndef DebugInfo_h
#define DebugInfo_h

#include "DisplayHandler.h"
#include <Arduino.h>

class DebugInfo {
    private:
        bool _enabled = false;
        DisplayHandler *_display_handler;
        int64_t last_dial_position;
        uint8_t _enter_button_pin;
        uint8_t _back_button_pin;
        bool _storing_config;
        bool _fetching_config;
        void clear();

    public:
        DebugInfo(
            DisplayHandler *display_handler,
            uint8_t enter_button_pin,
            uint8_t back_button_pin
        );
        void print();
        void showConfig(int64_t dial_position);
        void setFetching(bool fetching);
        void setStoring(bool storing);
};

#endif
