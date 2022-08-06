#ifndef DebugInfo_h
#define DebugInfo_h

#include "DisplayHandler.h"
#include "ButtonsHandler.h"
#include <Arduino.h>

class DebugInfo {
    private:
        bool _enabled = false;
        DisplayHandler *_display_handler;
        int64_t last_dial_position;
        ButtonsHandler * _buttons_handler;
        bool _storing_config;
        bool _fetching_config;
        void clear();

    public:
        DebugInfo(
            DisplayHandler *display_handler,
            ButtonsHandler *buttons_handler
        );
        void print();
        void showConfig(int64_t dial_position);
        void setFetching(bool fetching);
        void setStoring(bool storing);
};

#endif
