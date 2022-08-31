#include <assert.h>
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

#define VERSION_STRING "v1.0.5"

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
#define ITEM_INDEX_MEMORIES 101
#define ITEM_INDEX_MOVE 2
#define ITEM_INDEX_DEBUG 3

#define ITEM_INDEX_MOVE_UP 4
#define ITEM_INDEX_MOVE_DOWN 5
#define ITEM_INDEX_MOVE_FULL_UP 6
#define ITEM_INDEX_MOVE_FULL_DOWN 7
#define ITEM_INDEX_MOVE_1SEC_UP 61
#define ITEM_INDEX_MOVE_1SEC_DOWN 71

#define ITEM_INDEX_CALIBRATION 8
#define ITEM_INDEX_CALIBRATION_CURRENT_POSITION 9
#define ITEM_INDEX_CALIBRATION_UP_SPEED 10
#define ITEM_INDEX_CALIBRATION_DOWN_SPEED 11
#define ITEM_INDEX_CALIBRATION_DOWN_STATUS 12

#define ITEM_INDEX_MEMORIES_GOTO_M1 13
#define ITEM_INDEX_MEMORIES_GOTO_M2 14
#define ITEM_INDEX_MEMORIES_SET_M1 15
#define ITEM_INDEX_MEMORIES_SET_M2 16

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
WiFiManagerParameter wm_param_current_position_mm("current_position_mm", "Current Position (mm)", "position", 20);
WiFiManagerParameter wm_param_up_traverse_mm_sec("up_traverse_mm_sec", "Up traverse speed (mm/s)", "up traverse", 20);
WiFiManagerParameter wm_param_down_traverse_mm_sec("down_traverse_mm_sec", "Down traverse speed (mm/s)", "down traverse", 20);

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
Calibration calibration_storage(&on_corrupted_eeprom);
MotorDriver motor_driver(UP_RELAY_PIN, DOWN_RELAY_PIN);
DisplayHandler display_handler(&display);
ButtonsHandler buttons_handler(ENTER_BUTTON_PIN, BACK_BUTTON_PIN, true);
DebugInfo debug_info(&display_handler, &buttons_handler);

MenuItem main_menu[] = {
    {ITEM_INDEX_WIFI, "WiFi Cfg."},
    {ITEM_INDEX_CALIBRATION, "Calibr."},
    {ITEM_INDEX_MEMORIES, "Memories"},
    // {ITEM_INDEX_CLOCK, "Clock"},
    {ITEM_INDEX_MOVE, "Move"},
    {ITEM_INDEX_DEBUG, "Debug"},
};

MenuItem up_down_menu[] = {
    {ITEM_INDEX_MOVE_UP, "Up"},
    {ITEM_INDEX_MOVE_DOWN, "Down"},
    {ITEM_INDEX_MOVE_FULL_UP, "Full-Up"},
    {ITEM_INDEX_MOVE_FULL_DOWN, "Full-Down"},
    {ITEM_INDEX_MOVE_1SEC_UP, "1 sec. Up"},
    {ITEM_INDEX_MOVE_1SEC_DOWN, "1 sec. Down"},
};

MenuItem calibration_menu[] = {
    {ITEM_INDEX_CALIBRATION_CURRENT_POSITION, "Curr. Pos."},
    {ITEM_INDEX_CALIBRATION_UP_SPEED, "Up spd."},
    {ITEM_INDEX_CALIBRATION_DOWN_SPEED, "Down spd."},
    {ITEM_INDEX_CALIBRATION_DOWN_STATUS, "Status: "},
};

MenuItem memories_menu[] = {
    {ITEM_INDEX_MEMORIES_GOTO_M1, "M1 999 mm"},
    {ITEM_INDEX_MEMORIES_GOTO_M2, "M2 111 mm"},
    {ITEM_INDEX_MEMORIES_SET_M1, "Set M1"},
    {ITEM_INDEX_MEMORIES_SET_M2, "Set M2"},
};

MenuInstance main_menu_instance(
    &display_handler,
    main_menu,
    ARRAY_SIZE(main_menu),
    "Menu:",
    &buttons_handler
);

MenuInstance up_down_menu_instance(
    &display_handler,
    up_down_menu,
    ARRAY_SIZE(up_down_menu),
    "Move:",
    &buttons_handler
);

MenuInstance calibration_menu_instance(
    &display_handler,
    calibration_menu,
    ARRAY_SIZE(calibration_menu),
    "Calibration:",
    &buttons_handler
);

MenuInstance memories_menu_instance(
    &display_handler,
    memories_menu,
    ARRAY_SIZE(memories_menu),
    "Mem:",
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

    calibration_storage.fetch(calibration);

    setup_wifi_manager();

    calibration_menu_instance.setFontSize(1);
    display.dim(true);

    motor_driver.setOnCalibrationChangedCallback(&store_calibration);
    motor_driver.setCalibrationData(&calibration);
}

void setup_wifi_manager() {
    wifiManager.setPreOtaUpdateCallback(&on_pre_ota_update);
    wifiManager.setTitle("WIFI STANDING DESK");

    update_calibration_parameters();

    wifiManager.setParamsPage(true);
    wifiManager.setSaveParamsCallback(&on_params_save);
    wifiManager.addParameter(&wm_param_current_position_mm);
    wifiManager.addParameter(&wm_param_up_traverse_mm_sec);
    wifiManager.addParameter(&wm_param_down_traverse_mm_sec);
    wifiManager.setWebServerCallback(&config_api_endpoints);
}

void update_calibration_parameters() {
    wm_param_current_position_mm.setValue(String(calibration.current_position_mm).c_str(), 20);
    wm_param_up_traverse_mm_sec.setValue(String(calibration.up_traverse_mm_sec).c_str(), 20);
    wm_param_down_traverse_mm_sec.setValue(String(calibration.down_traverse_mm_sec).c_str(), 20);
}

void store_calibration() {
    update_calibration_parameters();
    calibration_storage.store(calibration);
}

void on_params_save() {
    calibration.current_position_mm = String(wm_param_current_position_mm.getValue()).toInt();
    calibration.up_traverse_mm_sec = String(wm_param_up_traverse_mm_sec.getValue()).toInt();
    calibration.down_traverse_mm_sec = String(wm_param_down_traverse_mm_sec.getValue()).toInt();
    store_calibration();
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

    wifiManager.server->on("/move_to", [&]() {
        String position_str = wifiManager.server->arg(String("target"));
        if (position_str.length() > 0) {
            int position = position_str.toInt();
            motor_driver.moveToTarget(position);
            wifiManager.server->send(200, "text/plain charset=utf-8", "Ok, going to target: " + String(position));
            return;
        }
        wifiManager.server->send(200, "text/plain charset=utf-8", "Error, must include target query param");
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
        case ITEM_INDEX_MEMORIES:
            return STATE_MEMORIES;
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
String this_parameter_is_selected(int current_parameter, int selected_parameter) {
    return current_parameter == selected_parameter ? "> " : "";
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
            String("Curr. pos.: " + String(calibration.current_position_mm) + " mm").toCharArray(calibration_menu[0].title, 20);
            String("Up spd.: " + String(calibration.up_traverse_mm_sec) + " mm/s").toCharArray(calibration_menu[1].title, 20);
            String("Down spd.: " + String(calibration.down_traverse_mm_sec) + " mm/s").toCharArray(calibration_menu[2].title, 20);
            String("Status: " + String(calibration.is_dirty ? "dirty" : "saved")).toCharArray(calibration_menu[3].title, 20);

            calibration_menu_instance.show();

            int selected_config = calibration_menu_instance.get_selection();

            static int64_t last_encoder_position = 0;
            int64_t current_encoder_position = encoder.getCount();

            if (buttons_handler.readEnterButton()) {
                if (last_encoder_position != current_encoder_position) {
                    switch (selected_config) {
                        case ITEM_INDEX_CALIBRATION_CURRENT_POSITION:
                            calibration.current_position_mm += current_encoder_position > last_encoder_position ? -1 : 1;
                            break;
                        case ITEM_INDEX_CALIBRATION_UP_SPEED:
                            calibration.up_traverse_mm_sec += current_encoder_position > last_encoder_position ? -1 : 1;
                            break;
                        case ITEM_INDEX_CALIBRATION_DOWN_SPEED:
                            calibration.down_traverse_mm_sec += current_encoder_position > last_encoder_position ? -1 : 1;
                            break;
                    }
                    calibration.is_dirty = true;
                    last_encoder_position = current_encoder_position;
                }
            } else {
                calibration_menu_instance.process(current_encoder_position);
                if (calibration.is_dirty) {
                    store_calibration();
                    calibration.is_dirty = false;
                }
            }
        }
        break;
        case STATE_MEMORIES: {
            String("M1 " + String(calibration.memory_m1_mm) + " mm").toCharArray(memories_menu[0].title, 20);
            String("M2 " + String(calibration.memory_m2_mm) + " mm").toCharArray(memories_menu[1].title, 20);

            memories_menu_instance.show();

            memories_menu_instance.setTitle("Mem: " + String(motor_driver.currentPositionInMM()));

            int selected_option = memories_menu_instance.get_selection();

            if (buttons_handler.readEnterButton() && !motor_driver.isMoving()) {
                switch (selected_option) {
                    case ITEM_INDEX_MEMORIES_GOTO_M1:
                        motor_driver.moveToTarget(calibration.memory_m1_mm);
                    break;
                    case ITEM_INDEX_MEMORIES_GOTO_M2:
                        motor_driver.moveToTarget(calibration.memory_m2_mm);
                    break;
                    case ITEM_INDEX_MEMORIES_SET_M1:
                        calibration.memory_m1_mm = motor_driver.currentPositionInMM();
                        store_calibration();
                    break;
                    case ITEM_INDEX_MEMORIES_SET_M2:
                        calibration.memory_m2_mm = motor_driver.currentPositionInMM();
                        store_calibration();
                    break;
                }
            }
        }
        break;
        case STATE_MOVE: {
            int selected_movement;
            up_down_menu_instance.show();
            // up_down_menu_instance.setTitle("Move " + String(motor_driver.currentPositionInMM()), "mm");
            up_down_menu_instance.setTitle("Move: " + String(motor_driver.currentPositionInMM()));
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
                    case ITEM_INDEX_MOVE_1SEC_UP:
                        motor_driver.moveUpForMillis(1000);
                        break;
                    case ITEM_INDEX_MOVE_1SEC_DOWN:
                        motor_driver.moveDownForMillis(1000);
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
    memories_menu_instance.process(encoder_count);

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
        last_wifi_check = millis();
    } else if (!is_wifi_enabled) {
        WiFi.disconnect(true);
        WiFi.mode(WIFI_OFF);
    }
}

bool wifi_check_timed_out(int last_wifi_check) {
    return millis() - last_wifi_check >= 2000;
}
