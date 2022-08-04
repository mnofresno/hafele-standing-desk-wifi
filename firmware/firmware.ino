#include <WiFiManager.h>
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <ESP32Encoder.h>
#include <esp_task_wdt.h>

#include "MenuInstance.h"
#include "MotorDriver.h"
#include "Calibration.h"
#include "DebugInfo.h"
#include "DisplayHandler.h"

#define __ASSERT_USE_STDERR

#include <assert.h>

// #include "soc/soc.h"
// #include "soc/rtc_cntl_reg.h"

#define VERSION_STRING "v1.0.4"

#define DEFAULT_FULL_UP_TIME_IN_SECS 18
#define DEFAULT_FULL_DOWN_TIME_IN_SECS 16

#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels

#define OLED_RESET     -1 // Reset pin # (or -1 if sharing Arduino reset pin)

#define STATE_CLOCK 0
#define STATE_MENU 1
#define STATE_WIFI_CONFIG 2
#define STATE_CALIBRATION 3
#define STATE_MEMORIES 4
#define STATE_MOVE 5
#define STATE_DEBUG_CONFIG 6

#define ITEM_INDEX_WIFI 1
#define ITEM_INDEX_MOVE 2
#define ITEM_INDEX_DEBUG 3
#define ITEM_INDEX_MOVE_UP 4
#define ITEM_INDEX_MOVE_DOWN 5
#define ITEM_INDEX_MOVE_FULL_UP 6
#define ITEM_INDEX_MOVE_FULL_DOWN 7
#define ITEM_INDEX_CALIBRATION 8

#define UP_RELAY_PIN 32
#define DOWN_RELAY_PIN 33

#define ENTER_BUTTON_PIN 34
#define BACK_BUTTON_PIN 35

#define ENCODER_PIN_A 18
#define ENCODER_PIN_B 19

#define ARRAY_SIZE(array) (sizeof(array)/sizeof((array)[0]))
#define WDT_TIMEOUT 2

ESP32Encoder encoder;
WiFiManager wifiManager;
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
MotorDriver motor_driver(UP_RELAY_PIN, DOWN_RELAY_PIN);
Calibration calibration_storage(&on_corrupted_eeprom);
DisplayHandler display_handler(&display);
DebugInfo debug_info(&display_handler, ENTER_BUTTON_PIN, BACK_BUTTON_PIN);

MenuItem main_menu[] = {
    {ITEM_INDEX_WIFI, "WiFi Cfg."},
    {ITEM_INDEX_CALIBRATION, "Calibr."},
    // {ITEM_INDEX_MEMORIES, "Memories"},
    // {ITEM_INDEX_CLOCK, "Clock"},
    {ITEM_INDEX_MOVE, "Move"},
    {ITEM_INDEX_DEBUG, "Debug"},
};

MenuItem up_down_menu[] = {
    {ITEM_INDEX_MOVE_UP, "Up"},
    {ITEM_INDEX_MOVE_DOWN, "Down"},
    {ITEM_INDEX_MOVE_FULL_UP, "Full-Up"},
    {ITEM_INDEX_MOVE_FULL_DOWN, "Full-Down"},
};

MenuInstance main_menu_instance(
    &display_handler,
    NULL,
    main_menu,
    ARRAY_SIZE(main_menu),
    "Menu:",
    ENTER_BUTTON_PIN,
    BACK_BUTTON_PIN
);

MenuInstance up_down_menu_instance(
    &display_handler,
    NULL,
    up_down_menu,
    ARRAY_SIZE(up_down_menu),
    "Move:",
    ENTER_BUTTON_PIN,
    BACK_BUTTON_PIN
);

int current_state = STATE_MENU;
int next_state = STATE_MENU;
static bool wdt_is_enabled = false;
CalibrationData calibration;

void debug_pointers() {
    static unsigned long last_time_update = millis();

    unsigned long current_millis = millis();

    if (current_millis - last_time_update > 2000) {
        Serial.printf("\nPunteros menus:");
        Serial.printf("\n%p", main_menu);
        Serial.printf("\n%p", up_down_menu);
        last_time_update = current_millis;
    }
}

void on_corrupted_eeprom() {
    display_handler.print_full_screen_with_title("Corrupt. Mem.", "Restoring defaults...");
}

void setup() {
    // WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);

    Serial.begin(115200);
    Serial.println();
    Serial.println("Starting Serial Port...");

    display_handler.draw_starting(VERSION_STRING);
    config_inputs_and_outputs();

    ESP32Encoder::useInternalWeakPullResistors=UP;
  	encoder.attachHalfQuad(ENCODER_PIN_B, ENCODER_PIN_A);

    WiFi.mode(WIFI_STA);
    wifiManager.setPreOtaUpdateCallback(&on_pre_ota_update);
    wifiManager.setTitle("WIFI STANDING DESK");
    calibration.current_position_mm = -999;
}

void on_pre_ota_update() {
    disable_wdt();
    display.clearDisplay();
    display_handler.print_full_screen_with_title("FW UPDATE", "Please wait...");
}

void config_inputs_and_outputs() {
    pinMode(BACK_BUTTON_PIN, INPUT);
    pinMode(ENTER_BUTTON_PIN, INPUT);
    pinMode(DOWN_RELAY_PIN, OUTPUT);
    pinMode(UP_RELAY_PIN, OUTPUT);
}

void config_api_endpoints() {
    static bool already_configured_endpoints = false;

    if (already_configured_endpoints) {
        return;
    }
    wifiManager.server->on("/up", [&]() {
        motor_driver.moveUpForMillis(500);
        wifiManager.server->send(200, "text/plain charset=utf-8", "Ok, going up");
    });

    wifiManager.server->on("/down", [&]() {
        motor_driver.moveDownForMillis(500);
        wifiManager.server->send(200, "text/plain charset=utf-8", "Ok, going down");
    });

    already_configured_endpoints = true;
}

void enable_wdt() {
    if (!wdt_is_enabled) {
        esp_task_wdt_init(WDT_TIMEOUT, true); //enable panic so ESP32 restarts
        esp_task_wdt_add(NULL); //add current thread to WDT watch
        wdt_is_enabled = true;
    }
}

void disable_wdt() {
    if (wdt_is_enabled) {
        esp_task_wdt_init(60, false); //enable panic so ESP32 restarts
        esp_task_wdt_add(NULL); //add current thread to WDT watch
        wdt_is_enabled = false;
    }
}

void handle_states_machine() {
    current_state = next_state;

    switch (current_state) {
        case STATE_MENU: {
            int selected_item;

            main_menu_instance.show();

            selected_item = main_menu_instance.get_selection();

            if (selected_item == MENU_ITEM_GO_BACK) next_state = STATE_CLOCK;

            if (selected_item == ITEM_INDEX_WIFI) next_state = STATE_WIFI_CONFIG;
            if (selected_item == ITEM_INDEX_CALIBRATION) next_state = STATE_CALIBRATION;
            // if (selected_item == ITEM_INDEX_MEMORIES) next_state = STATE_MEMORIES;
            // if (selected_item == ITEM_INDEX_CLOCK) next_state = STATE_CLOCK;
            if (selected_item == ITEM_INDEX_MOVE) next_state = STATE_MOVE;
            if (selected_item == ITEM_INDEX_DEBUG) next_state = STATE_DEBUG_CONFIG;

            if (selected_item == 0) next_state = STATE_MENU;
        }
        break;
        case STATE_CLOCK: {
            Serial.println("Clock...");
            display_handler.show_message("CLOCK!");
            set_next_state(STATE_CLOCK);
        }
        break;
        case STATE_WIFI_CONFIG: {
            String wifi_output;
            if (WiFi.isConnected()) {
                wifi_output += "Connected to:\n" + String(WiFi.SSID());
                wifi_output += "\nIP Address:\n" + WiFi.localIP().toString();
            } else {
                wifi_output += "Not connected :(";
            }
            display_handler.print_full_screen_with_title("WiFi", "Status:\n" + wifi_output);

            set_next_state(STATE_WIFI_CONFIG);
        }
        break;
        case STATE_CALIBRATION: {
            static int current_position = 0;
            if (calibration.current_position_mm == -999) {
                debug_info.setFetching(true);
                calibration = calibration_storage.fetch();
                debug_info.setFetching(false);
                current_position = calibration.current_position_mm;
            } else if (current_position != 0 && current_position != calibration.current_position_mm && digitalRead(BACK_BUTTON_PIN) == HIGH) {
                debug_info.setStoring(true);
                calibration_storage.store(calibration);
                debug_info.setStoring(false);
            }

            static int64_t last_encoder_position = 0;
            int64_t current_encoder_position = encoder.getCount();
            if (last_encoder_position != current_encoder_position) {
                current_position += current_encoder_position > last_encoder_position ? -1 : 1;
                last_encoder_position = current_encoder_position;
            }

            display_handler.print_full_screen_with_title("CALIBR.", "Current pos: " + String(current_position) + " mm");

            set_next_state(STATE_CALIBRATION);
        }
        break;
        case STATE_MEMORIES: {
            Serial.println("Mem...");
            display_handler.show_message("MEMORIES!");
            set_next_state(STATE_MEMORIES);
        }
        break;
        case STATE_MOVE: {
            int selected_movement;

            up_down_menu_instance.show();

            selected_movement = up_down_menu_instance.get_selection();
            static bool manual_moving = false;
            if (!digitalRead(ENTER_BUTTON_PIN)) {
                switch (selected_movement) {
                    case ITEM_INDEX_MOVE_UP:
                        manual_moving = true;
                        motor_driver.moveUp();
                        break;
                    case ITEM_INDEX_MOVE_DOWN:
                        manual_moving = true;
                        motor_driver.moveDown();
                        break;
                    case ITEM_INDEX_MOVE_FULL_UP:
                        motor_driver.moveUpForMillis(DEFAULT_FULL_UP_TIME_IN_SECS * 1000);
                        break;
                    case ITEM_INDEX_MOVE_FULL_DOWN:
                        motor_driver.moveDownForMillis(DEFAULT_FULL_DOWN_TIME_IN_SECS * 1000);
                        break;
                }
            } else {
                if (manual_moving) {
                    motor_driver.stop();
                    manual_moving = false;
                }
            }

            set_next_state(STATE_MOVE);
        }
        break;
        case STATE_DEBUG_CONFIG: {
            debug_info.showConfig(encoder.getCount());
            set_next_state(STATE_DEBUG_CONFIG);
        }
        break;
    }

    if (next_state != current_state) {
        display.clearDisplay();
    }
}

void set_next_state(int state) {
    next_state = state;
    if (digitalRead(BACK_BUTTON_PIN) == HIGH) {
        next_state = STATE_MENU;
    }
}

void loop() {
    wifiManager.process();
    handle_states_machine();
    debug_info.print();
    int64_t encoder_count = encoder.getCount();
    main_menu_instance.process(encoder_count);
    up_down_menu_instance.process(encoder_count);
    motor_driver.run();
    reset_wdt();
    tryToConnectWifi();
    debug_pointers();
}

void reset_wdt() {
    static unsigned long last_wdt_reset = millis();
    if (millis() - last_wdt_reset >= (1000 * WDT_TIMEOUT) / 2) {
        esp_task_wdt_reset();
        last_wdt_reset = millis();
    }
}

void tryToConnectWifi() {
    static unsigned long last_wifi_check = 0;
    if (!WiFi.isConnected() && wifi_check_timed_out(last_wifi_check)) {
        wifiManager.setConfigPortalBlocking(false);
        wifiManager.startConfigPortal();
        WiFi.begin();
        // wifiManager.autoConnect("WIFI_STANDING_DESK","PASSWORD");
        config_api_endpoints();
        last_wifi_check = millis();
    }
}

bool wifi_check_timed_out(int last_wifi_check) {
    return millis() - last_wifi_check >= 2000;
}
