#ifndef MotorDriver_h
#define MotorDriver_h

#include <Arduino.h>

#define MOVE_STATE_UP 1
#define MOVE_STATE_DOWN 2
#define MOVE_STATE_STOP 3

class MotorDriver {
    private:
        uint8_t _motor_up_pin;
        uint8_t _motor_down_pin;
        unsigned long _started_movement_at = 0;
        unsigned long _duration = 0; /** When = 0, implies infinity */
        unsigned int _current_move_state = MOVE_STATE_STOP;
        unsigned int _expected_state = MOVE_STATE_STOP;
        bool timedOut();
        void doMoveUp();
        void doMoveDown();
        void doStop();

    public:
        MotorDriver(
            uint8_t motor_up_pin,
            uint8_t motor_down_pin
        );
        void moveUpForMillis(unsigned long duration);
        void moveDownForMillis(unsigned long duration);
        void moveForMillis(int direction, unsigned long duration);
        void moveUp();
        void moveDown();
        void stop();
        void run();
};
#endif
