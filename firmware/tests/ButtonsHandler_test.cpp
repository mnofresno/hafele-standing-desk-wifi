#include <unity.h>
#include "ButtonsHandler.h"

// Mock de las funciones de Arduino
unsigned long mock_millis = 0;
unsigned long millis() {
    return mock_millis;
}

int mock_digital_read_pin = 0;
int mock_digital_read_value = 0;
int digitalRead(int pin) {
    mock_digital_read_pin = pin;
    return mock_digital_read_value;
}

void setUp(void) {
    mock_millis = 0;
    mock_digital_read_value = 0;
}

void tearDown(void) {
    // cleanup stuff
}

void test_long_press_detection() {
    ButtonsHandler buttons(34, 35);
    
    // Simular botón presionado
    mock_digital_read_value = HIGH;
    
    // Verificar que no se detecta pulsación larga al inicio
    TEST_ASSERT_FALSE(buttons.readBackButtonLongPress());
    
    // Avanzar el tiempo a 2.9 segundos
    mock_millis = 2900;
    TEST_ASSERT_FALSE(buttons.readBackButtonLongPress());
    
    // Avanzar el tiempo a 3 segundos
    mock_millis = 3000;
    TEST_ASSERT_TRUE(buttons.readBackButtonLongPress());
    
    // Verificar que no se detecta otra pulsación larga inmediatamente
    TEST_ASSERT_FALSE(buttons.readBackButtonLongPress());
}

void test_long_press_interrupted() {
    ButtonsHandler buttons(34, 35);
    
    // Simular botón presionado
    mock_digital_read_value = HIGH;
    
    // Avanzar el tiempo a 1.5 segundos
    mock_millis = 1500;
    TEST_ASSERT_FALSE(buttons.readBackButtonLongPress());
    
    // Simular que se suelta el botón
    mock_digital_read_value = LOW;
    TEST_ASSERT_FALSE(buttons.readBackButtonLongPress());
    
    // Volver a presionar y avanzar a 3 segundos
    mock_digital_read_value = HIGH;
    mock_millis = 3000;
    TEST_ASSERT_FALSE(buttons.readBackButtonLongPress());
}

void RUN_UNITY_TESTS() {
    UNITY_BEGIN();
    RUN_TEST(test_long_press_detection);
    RUN_TEST(test_long_press_interrupted);
    UNITY_END();
}

int main(int argc, char **argv) {
    RUN_UNITY_TESTS();
    return 0;
} 