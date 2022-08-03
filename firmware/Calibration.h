#ifndef Calibration_h
#define Calibration_h

#include <Arduino.h>

#define EEPROM_SALT 46126

typedef struct CalibrationData {
    int salt = EEPROM_SALT;
    int up_traverse_mm_sec = 15;
    int down_traverse_mm_sec = 20;
    int current_position_mm = 500;
};

class Calibration {
    private:
        void read_eeprom();
        void save_eeprom();
        CalibrationData _data;

    public:
        Calibration(std::function<void()> onCorruptedEepromCallback);
        CalibrationData fetch();
        void store(CalibrationData data);
};
#endif
