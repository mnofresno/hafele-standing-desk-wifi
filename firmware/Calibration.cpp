#include "Calibration.h"
#include <ArduinoJson.h>

Calibration::Calibration(std::function<void()> onCorruptedEepromCallback) {
    _onCorruptedEepromCallback = onCorruptedEepromCallback;
}

void Calibration::fetch(CalibrationData &data) {
    _preferences.begin("StandingDesk", false);

    String serializedSettings = _preferences.getString("settings", "{\"current_position_mm\":-1}");
    DynamicJsonDocument parsedJson(1024);

    deserializeJson(parsedJson, serializedSettings);

    data.current_position_mm = parsedJson["current_position_mm"];
    if (data.current_position_mm == -1) {
        data = {};
        _onCorruptedEepromCallback();
    }
    data.down_traverse_mm_sec = parsedJson["down_traverse_mm_sec"];
    data.up_traverse_mm_sec = parsedJson["up_traverse_mm_sec"];
    data.memory_m1_mm = parsedJson["memory_m1_mm"];
    data.memory_m2_mm = parsedJson["memory_m2_mm"];
    data.is_dirty = false;


    _preferences.end();
}

void Calibration::store(CalibrationData &data) {
    _preferences.begin("StandingDesk", false);

    DynamicJsonDocument parsedJson(1024);

    parsedJson["current_position_mm"] = data.current_position_mm;
    parsedJson["down_traverse_mm_sec"] = data.down_traverse_mm_sec;
    parsedJson["up_traverse_mm_sec"] = data.up_traverse_mm_sec;
    parsedJson["memory_m1_mm"] = data.memory_m1_mm;
    parsedJson["memory_m2_mm"] = data.memory_m2_mm;

    String serializedJson;

    serializeJson(parsedJson, serializedJson);

    _preferences.putString("settings", serializedJson);

    data.is_dirty = false;

    _preferences.end();
}
