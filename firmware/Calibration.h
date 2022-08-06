#ifndef Calibration_h
#define Calibration_h

#include <Arduino.h>
#include <Preferences.h>

#define EEPROM_SALT 46126

typedef struct CalibrationData {
    int up_traverse_mm_sec = 15;
    int down_traverse_mm_sec = 20;
    int current_position_mm = 500;
    bool is_dirty = false;
};

class Calibration {
    private:
        std::function<void()> _onCorruptedEepromCallback;
        Preferences _preferences;
    public:
        Calibration(std::function<void()> onCorruptedEepromCallback);
        void fetch(CalibrationData &data);
        void store(CalibrationData &data);
};
#endif
