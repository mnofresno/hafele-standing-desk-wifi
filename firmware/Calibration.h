#ifndef Calibration_h
#define Calibration_h

#include <Arduino.h>
#include <Preferences.h>

#define EEPROM_SALT 46126

typedef struct CalibrationData {
    unsigned int up_traverse_mm_sec = 15;
    unsigned int down_traverse_mm_sec = 20;
    unsigned int current_position_mm = 500;
    unsigned int memory_m1_mm = 700;
    unsigned int memory_m2_mm = 800;
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
