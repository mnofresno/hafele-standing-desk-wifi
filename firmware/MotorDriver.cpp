#include "MotorDriver.h"

MotorDriver::MotorDriver(
    uint8_t motor_up_pin,
    uint8_t motor_down_pin
) {
    _motor_up_pin = motor_up_pin;
    _motor_down_pin = motor_down_pin;
}

void MotorDriver::process() {
}

void MotorDriver::moveUpForMillis(int duration) {
    moveUp();
    delay(duration);
    moveStop();
}

void MotorDriver::moveDownForMillis(int duration) {
    moveDown();
    delay(duration);
    moveStop();
}

void MotorDriver::moveUp() {
    // enable_wdt();
    digitalWrite(_motor_up_pin, HIGH);
    digitalWrite(_motor_down_pin, LOW);
}

void MotorDriver::moveDown() {
    // enable_wdt();
    digitalWrite(_motor_down_pin, HIGH);
    digitalWrite(_motor_up_pin, LOW);
}

void MotorDriver::moveStop() {
    digitalWrite(_motor_up_pin, LOW);
    digitalWrite(_motor_down_pin, LOW);
    // disable_wdt();
}
