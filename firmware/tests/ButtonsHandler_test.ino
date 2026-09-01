#include <unity.h>
#include "../ButtonsHandler.h"

ButtonsHandler buttons(34, 35);

void setUp(void) {
    // setup stuff
}

void tearDown(void) {
    // cleanup stuff
}

void test_long_press_detection() {
    // Simulate button press
    digitalWrite(35, HIGH);
    
    // Verify no long press detected at start
    TEST_ASSERT_FALSE(buttons.readBackButtonLongPress());
    
    // Wait 2.9 seconds
    delay(2900);
    TEST_ASSERT_FALSE(buttons.readBackButtonLongPress());
    
    // Wait until 3 seconds
    delay(100);
    TEST_ASSERT_TRUE(buttons.readBackButtonLongPress());
    
    // Verify no immediate long press detection
    TEST_ASSERT_FALSE(buttons.readBackButtonLongPress());
}

void test_long_press_interrupted() {
    // Simulate button press
    digitalWrite(35, HIGH);
    
    // Wait 1.5 seconds
    delay(1500);
    TEST_ASSERT_FALSE(buttons.readBackButtonLongPress());
    
    // Simulate button release
    digitalWrite(35, LOW);
    TEST_ASSERT_FALSE(buttons.readBackButtonLongPress());
    
    // Press again and wait 3 seconds
    digitalWrite(35, HIGH);
    delay(3000);
    TEST_ASSERT_FALSE(buttons.readBackButtonLongPress());
}

void setup() {
    delay(2000);
    UNITY_BEGIN();
    RUN_TEST(test_long_press_detection);
    RUN_TEST(test_long_press_interrupted);
    UNITY_END();
}

void loop() {
    // nothing to do here
} 