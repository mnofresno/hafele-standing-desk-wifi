#include "ButtonsHandler.h"
#include <cassert>
#include <iostream>

unsigned long mock_millis = 0;
int mock_digital_read_value = LOW;

unsigned long millis() {
    return mock_millis;
}

int digitalRead(int) {
    return mock_digital_read_value;
}

void pinMode(int, int) {}

void test_long_press_detection() {
    ButtonsHandler buttons(34, 35);
    mock_digital_read_value = HIGH;

    assert(!buttons.readBackButtonLongPress());
    mock_millis = 2900;
    assert(!buttons.readBackButtonLongPress());
    mock_millis = 3000;
    assert(buttons.readBackButtonLongPress());
    assert(!buttons.readBackButtonLongPress());
}

void test_long_press_interrupted() {
    ButtonsHandler buttons(34, 35);
    mock_digital_read_value = HIGH;

    assert(!buttons.readBackButtonLongPress());
    mock_millis = 1500;
    assert(!buttons.readBackButtonLongPress());
    mock_digital_read_value = LOW;
    assert(!buttons.readBackButtonLongPress());
    mock_digital_read_value = HIGH;
    mock_millis = 3000;
    assert(!buttons.readBackButtonLongPress());
}

void test_button_debounce_storage() {
    ButtonsHandler buttons(34, 35);
    mock_digital_read_value = LOW;
    assert(!buttons.readEnterButton());
    assert(!buttons.readBackButton());

    mock_digital_read_value = HIGH;
    mock_millis = 100;
    assert(!buttons.readEnterButton());
    assert(!buttons.readBackButton());
    mock_millis = 160;
    assert(buttons.readEnterButton());
    assert(buttons.readBackButton());
}

int main() {
    test_long_press_detection();
    mock_millis = 0;
    test_long_press_interrupted();
    mock_millis = 0;
    test_button_debounce_storage();
    std::cout << "ButtonsHandler tests passed\n";
}
