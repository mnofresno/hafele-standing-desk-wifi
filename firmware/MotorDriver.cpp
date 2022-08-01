#include "MotorDriver.h"

MotorDriver::MotorDriver(
    uint8_t motor_up_pin,
    uint8_t motor_down_pin
) {
    _motor_up_pin = motor_up_pin;
    _motor_down_pin = motor_down_pin;
}

void MotorDriver::run() {
    if (
        _current_move_state != _expected_state
    ) {
        switch (_expected_state) {
            case MOVE_STATE_UP:
                doMoveUp();
                _current_move_state = MOVE_STATE_UP;
                break;
            case MOVE_STATE_DOWN:
                doMoveDown();
                _current_move_state = MOVE_STATE_DOWN;
                break;
            case MOVE_STATE_STOP:
                doStop();
                _current_move_state = MOVE_STATE_STOP;
                break;
        }
    }

    if (_current_move_state != MOVE_STATE_STOP && timedOut() && _duration != 0) {
        _expected_state = MOVE_STATE_STOP;
        _duration = 0;
    }
}

bool MotorDriver::timedOut() {
    return millis() - _started_movement_at >= _duration;
}

void MotorDriver::moveForMillis(int direction, unsigned long duration) {
    _started_movement_at = millis();
    _expected_state = direction;
    _duration = duration;
}

void MotorDriver::moveUpForMillis(unsigned long duration) {
    moveForMillis(MOVE_STATE_UP, duration);
}

void MotorDriver::moveDownForMillis(unsigned long duration) {
    moveForMillis(MOVE_STATE_DOWN, duration);
}

void MotorDriver::doMoveUp() {
    // enable_wdt();
    digitalWrite(_motor_up_pin, HIGH);
    digitalWrite(_motor_down_pin, LOW);
}

void MotorDriver::doMoveDown() {
    // enable_wdt();
    digitalWrite(_motor_down_pin, HIGH);
    digitalWrite(_motor_up_pin, LOW);
}

void MotorDriver::doStop() {
    digitalWrite(_motor_up_pin, LOW);
    digitalWrite(_motor_down_pin, LOW);
    // disable_wdt();
}

void MotorDriver::moveUp() {
    _expected_state = MOVE_STATE_UP;
    _duration = 0;
}

void MotorDriver::moveDown() {
    _expected_state = MOVE_STATE_DOWN;
    _duration = 0;
}

void MotorDriver::stop() {
    _expected_state = MOVE_STATE_STOP;
    _duration = 0;
}
