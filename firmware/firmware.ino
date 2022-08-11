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
#include "ButtonsHandler.h"

#define __ASSERT_USE_STDERR

#include <assert.h>

#define VERSION_STRING "v1.0.4"

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
ButtonsHandler buttons_handler(ENTER_BUTTON_PIN, BACK_BUTTON_PIN, true);
DebugInfo debug_info(&display_handler, &buttons_handler);

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
    &buttons_handler
);

MenuInstance up_down_menu_instance(
    &display_handler,
    NULL,
    up_down_menu,
    ARRAY_SIZE(up_down_menu),
    "Move:",
    &buttons_handler
);

int current_state = STATE_MENU;
int next_state = STATE_MENU;
static bool wdt_is_enabled = false;
CalibrationData calibration;
bool is_wifi_enabled = true;
int use_ap_or_station = WIFI_STA;

void on_corrupted_eeprom() {
    display_handler.print_full_screen_with_title("Invalid Cfg.", "Restore default...");
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

    calibration_storage.fetch(calibration);
}

void on_pre_ota_update() {
    disable_wdt();
    display.clearDisplay();
    display_handler.print_full_screen_with_title("FW UPDATE", "Please wait...");
}

void config_inputs_and_outputs() {
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
        motor_driver.moveDownForMillis(400);
        wifiManager.server->send(200, "text/plain charset=utf-8", "Ok, going down");
    });

    wifiManager.server->on("/full_up", [&]() {
        motor_driver.moveFullUp();
        wifiManager.server->send(200, "text/plain charset=utf-8", "Ok, going FULL up");
    });

    wifiManager.server->on("/full_down", [&]() {
        motor_driver.moveFullDown();
        wifiManager.server->send(200, "text/plain charset=utf-8", "Ok, going FULL down");
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

int menu_item_to_state(int selected_item) {
    switch (selected_item) {
        case MENU_ITEM_GO_BACK:
            return STATE_CLOCK;
        case ITEM_INDEX_WIFI:
            return STATE_WIFI_CONFIG;
        case ITEM_INDEX_CALIBRATION:
            return STATE_CALIBRATION;
        // case ITEM_INDEX_MEMORIES:
        //     return STATE_MEMORIES;
        // case ITEM_INDEX_CLOCK:
        //     return STATE_CLOCK;
        case ITEM_INDEX_MOVE:
            return STATE_MOVE;
        case ITEM_INDEX_DEBUG:
            return STATE_DEBUG_CONFIG;
        default:
            return STATE_MENU;
    }
}

void wifi_print_connected() {
    display_handler.println_with_pad("Connected to:");
    display_handler.println_with_pad(String(WiFi.SSID()));
    display_handler.println_with_pad("IP Address:");
    display_handler.println_with_pad(WiFi.localIP().toString());
}

void wifi_print_disconnected() {
    String selector = use_ap_or_station == WIFI_STA ? "<-" : "->";
    display_handler.println_with_pad("Not connected :(");
    display_handler.println_with_pad("Press encoder button");
    display_handler.println_with_pad("to re-connect WiFi.");
    display_handler.println_with_pad("STA " + selector + " AP");
}

void wifi_print_connecting(String connecting_bar) {
    display_handler.println_with_pad("");
    display_handler.println_with_pad("Connecting" + connecting_bar);
    display_handler.println_with_pad("");
    display_handler.println_with_pad("");
}

int states_transformation() {
    switch (current_state) {
        case STATE_MENU: {
            main_menu_instance.show();
            return menu_item_to_state(
                main_menu_instance.get_selection()
            );
        }
        case STATE_CLOCK: {
            Serial.println("Clock...");
            display_handler.show_message("CLOCK!");
        }
        break;
        case STATE_WIFI_CONFIG: {
            static String connecting_bar = "";
            static bool connecting = false;
            static int64_t last_dial_position = encoder.getCount();
            display_handler.print_full_screen_with_title("WiFi", "Status:");
            if (WiFi.isConnected()) {
                wifi_print_connected();
                connecting = false;
            } else if (connecting) {
                wifi_print_connecting(connecting_bar);
                display_handler.anti_flickering([&](){
                    connecting_bar += ".";
                }, 200);
            } else {
                wifi_print_disconnected();
                if (last_dial_position != encoder.getCount()) {
                    use_ap_or_station = use_ap_or_station == WIFI_STA ? WIFI_AP : WIFI_STA;
                    last_dial_position = encoder.getCount();
                }
            }
            if (buttons_handler.readEnterButton()) {
                is_wifi_enabled = ! is_wifi_enabled;
                if (is_wifi_enabled) {
                    connecting = true;
                    connecting_bar = "";
                }
            }
        }
        break;
        case STATE_CALIBRATION: {
            if (calibration.is_dirty && buttons_handler.readEnterButton()) {
                debug_info.setStoring(true);
                Serial.println("\nStoring...\n");
                calibration_storage.store(calibration);
                debug_info.setStoring(false);
                Serial.println("\nStored OK...\n");
                calibration.is_dirty = false;
            }

            static int64_t last_encoder_position = 0;
            int64_t current_encoder_position = encoder.getCount();
            if (last_encoder_position != current_encoder_position) {
                calibration.current_position_mm += current_encoder_position > last_encoder_position ? -1 : 1;
                last_encoder_position = current_encoder_position;
                calibration.is_dirty = true;
            }

            char buffer[40];

            sprintf(
                buffer,
                "Current pos: %i mm\n%s",
                calibration.current_position_mm,
                calibration.is_dirty ? "" : "Saved"
            );

            display_handler.print_full_screen_with_title(
                "CALIBR.",
                String(buffer)
            );
        }
        break;
        case STATE_MEMORIES: {
            Serial.println("Mem...");
            display_handler.show_message("MEMORIES!");
        }
        break;
        case STATE_MOVE: {
            int selected_movement;
            up_down_menu_instance.show();
            enable_wdt();
            selected_movement = up_down_menu_instance.get_selection();
            static bool manual_moving = false;
            if (buttons_handler.readEnterButton()) {
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
                        motor_driver.moveFullUp();
                        break;
                    case ITEM_INDEX_MOVE_FULL_DOWN:
                        motor_driver.moveFullDown();
                        break;
                }
            } else {
                if (manual_moving) {
                    motor_driver.stop();
                    manual_moving = false;
                }
            }
            disable_wdt();
        }
        break;
        case STATE_DEBUG_CONFIG: {
            debug_info.showConfig(encoder.getCount());
        }
        break;
    }
    return get_next_state_or_back(current_state);
}

void handle_states_machine() {
    current_state = next_state;
    next_state = states_transformation();
    bool has_changed_state = next_state != current_state;
    buttons_handler.process(has_changed_state);
    if (has_changed_state) {
        display.clearDisplay();
    }
}

int get_next_state_or_back(int state) {
    if (buttons_handler.readBackButton()) {
        return STATE_MENU;
    }
    return state;
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
    try_to_connect_wifi();
}

void reset_wdt() {
    static unsigned long last_wdt_reset = millis();
    if (millis() - last_wdt_reset >= (1000 * WDT_TIMEOUT) / 2) {
        esp_task_wdt_reset();
        last_wdt_reset = millis();
    }
}

void try_to_connect_wifi() {
    static unsigned long last_wifi_check = 0;
    if (is_wifi_enabled && !WiFi.isConnected() && wifi_check_timed_out(last_wifi_check)) {
        wifiManager.setConfigPortalBlocking(false);
        wifiManager.startConfigPortal();
        if (use_ap_or_station == WIFI_STA) {
            WiFi.begin();
        } else {
            wifiManager.autoConnect("WIFI_STANDING_DESK","PASSWORD");
        }
        config_api_endpoints();
        last_wifi_check = millis();
    } else if (!is_wifi_enabled) {
        WiFi.disconnect(true);
        WiFi.mode(WIFI_OFF);
    }
}

bool wifi_check_timed_out(int last_wifi_check) {
    return millis() - last_wifi_check >= 2000;
}
