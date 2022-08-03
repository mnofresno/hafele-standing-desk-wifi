#include "Calibration.h"
#include <EEPROM.h>


Calibration::Calibration(std::function<void()> onCorruptedEepromCallback) {}

CalibrationData Calibration::fetch() {
    read_eeprom();
    if (_data.salt != EEPROM_SALT) {
        Serial.println("Invalid settings in EEPROM, trying with defaults");
        CalibrationData defaults;
        _data = defaults;
    }
    return _data;
}

void Calibration::store(CalibrationData data) {
    _data = data;
    save_eeprom();
}

void Calibration::read_eeprom() {
    EEPROM.begin(512);
    EEPROM.get(0, _data);
    EEPROM.end();
}

void Calibration::save_eeprom() {
    EEPROM.begin(512);
    EEPROM.put(0, _data);
    EEPROM.commit();
    EEPROM.end();
}
