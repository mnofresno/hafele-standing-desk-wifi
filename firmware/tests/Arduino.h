#ifndef TEST_ARDUINO_H
#define TEST_ARDUINO_H

#include <cstdint>
#include <string>

using uint8_t = std::uint8_t;
constexpr int LOW = 0;
constexpr int HIGH = 1;
constexpr int INPUT = 0;

unsigned long millis();
int digitalRead(int pin);
void pinMode(int pin, int mode);

class String {
    std::string value;

public:
    String() = default;
    String(const char *input) : value(input ? input : "") {}
    String(int input) : value(std::to_string(input)) {}
    String(bool input) : value(input ? "1" : "0") {}

    String operator+(const String &other) const {
        return String((value + other.value).c_str());
    }

    String operator+(const char *other) const {
        return String((value + (other ? other : "")).c_str());
    }
};

inline String operator+(const char *left, const String &right) {
    return String(left) + right;
}

#endif
