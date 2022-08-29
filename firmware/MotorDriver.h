#ifndef MotorDriver_h
#define MotorDriver_h

#include <Arduino.h>
#include "Calibration.h"

#define MOVE_STATE_UP 1
#define MOVE_STATE_DOWN 2
#define MOVE_STATE_STOP 3

#define DEFAULT_FULL_UP_TIME_IN_SECS 18
#define DEFAULT_FULL_DOWN_TIME_IN_SECS 16
#define MAX_HEIGHT_MM 1220
#define MIN_HEIGHT_MM 725
#define HEIGHT_MARGIN 10

class MotorDriver {
    private:
        uint8_t _motor_up_pin;
        uint8_t _motor_down_pin;
        unsigned long _started_movement_at = 0;
        unsigned long _duration = 0; /** When = 0, implies infinity */
        unsigned int _current_move_state = MOVE_STATE_STOP;
        unsigned int _expected_state = MOVE_STATE_STOP;
        unsigned int _initial_position_mm;
        std::function<void()> _onCalibrationChangedCallback;
        CalibrationData *_calibration;
        void moveForMillis(int direction, unsigned long duration);
        bool timedOut();
        bool carriedOut();
        void doMoveUp();
        void doMoveDown();
        void doStop();
        void _update_position();
        int _speed();
        unsigned int _elapsed_time();
        void _started_movement();
        bool _moving_up();
        bool _moving_down();
        void calibrationChanged();

    public:
        MotorDriver(
            uint8_t motor_up_pin,
            uint8_t motor_down_pin
        );
        void setOnCalibrationChangedCallback(std::function<void()> callback);
        void setCalibrationData(CalibrationData *calibration);
        void moveUpForMillis(unsigned long duration);
        void moveDownForMillis(unsigned long duration);
        void moveFullUp();
        void moveFullDown();
        void moveUp();
        void moveDown();
        void stop();
        void run();
        unsigned int currentPositionInMM();
};
#endif
