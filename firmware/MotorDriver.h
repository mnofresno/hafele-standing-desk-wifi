#ifndef MotorDriver_h
#define MotorDriver_h

#include <Arduino.h>

class MotorDriver {
    private:
        uint8_t _motor_up_pin;
        uint8_t _motor_down_pin;
    public:
        MotorDriver(
            uint8_t motor_up_pin,
            uint8_t motor_down_pin
        );
        void moveUpForMillis(int duration);
        void moveDownForMillis(int duration);
        void moveUp();
        void moveDown();
        void moveStop();
        void process();

};
#endif
