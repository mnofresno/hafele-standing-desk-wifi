#include "MotorDriver.h"

MotorDriver::MotorDriver(
    uint8_t motor_up_pin,
    uint8_t motor_down_pin
) {
    _motor_up_pin = motor_up_pin;
    _motor_down_pin = motor_down_pin;
}

void MotorDriver::run() {
    _update_position();
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

    if ((_current_move_state != MOVE_STATE_STOP && timedOut() && _duration != 0) || carriedOut()) {
        stop();
    }
}

bool MotorDriver::timedOut() {
    return _elapsed_time() >= _duration;
}

bool MotorDriver::carriedOut() {
    return (_moving_up() && currentPositionInMM() > (MAX_HEIGHT_MM - HEIGHT_MARGIN))
        || (_moving_down() && currentPositionInMM() < (MIN_HEIGHT_MM + HEIGHT_MARGIN));
}

void MotorDriver::_started_movement() {
    if (_started_movement_at == 0) {
        _started_movement_at = millis();
    }
}

void MotorDriver::moveForMillis(int direction, unsigned long duration) {
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
    if (carriedOut()) {
        return;
    }
    _started_movement();
    // enable_wdt();
    digitalWrite(_motor_up_pin, HIGH);
    digitalWrite(_motor_down_pin, LOW);
}

void MotorDriver::doMoveDown() {
    if (carriedOut()) {
        return;
    }
    _started_movement();
    // enable_wdt();
    digitalWrite(_motor_down_pin, HIGH);
    digitalWrite(_motor_up_pin, LOW);
}

void MotorDriver::doStop() {
    digitalWrite(_motor_up_pin, LOW);
    digitalWrite(_motor_down_pin, LOW);
    _initial_position_mm = _calibration->current_position_mm;
    _started_movement_at = 0;
    calibrationChanged();
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

void MotorDriver::moveFullDown() {
    moveDownForMillis(DEFAULT_FULL_DOWN_TIME_IN_SECS * 1000);
}

void MotorDriver::moveFullUp() {
    moveUpForMillis(DEFAULT_FULL_UP_TIME_IN_SECS * 1000);
}

unsigned int MotorDriver::currentPositionInMM() {
    return _calibration->current_position_mm;
}

void MotorDriver::_update_position() {
    if (_current_move_state != MOVE_STATE_STOP) {
        _calibration->current_position_mm = _initial_position_mm + _speed() * (_elapsed_time() / 1000.0);
    }
}

unsigned int MotorDriver::_elapsed_time() {
    return millis() - _started_movement_at;
}

int MotorDriver::_speed() {
    return _moving_up()
        ? _calibration->up_traverse_mm_sec
        : -_calibration->down_traverse_mm_sec;
}

bool MotorDriver::_moving_up() {
    return _current_move_state == MOVE_STATE_UP;
}

bool MotorDriver::_moving_down() {
    return _current_move_state == MOVE_STATE_DOWN;
}

void MotorDriver::setOnCalibrationChangedCallback(std::function<void()> callback) {
    _onCalibrationChangedCallback = callback;
}

void MotorDriver::setCalibrationData(CalibrationData *calibration) {
    _calibration = calibration;
    _initial_position_mm = _calibration->current_position_mm;
}

void MotorDriver::calibrationChanged() {
    if (_onCalibrationChangedCallback != NULL) {
        _onCalibrationChangedCallback();
    }
}
