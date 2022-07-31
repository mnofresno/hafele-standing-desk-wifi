#include <WiFiManager.h>
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <ESP32Encoder.h>
#include "MenuInstance.h"
#include <esp_task_wdt.h>

// #include "soc/soc.h"
// #include "soc/rtc_cntl_reg.h"

#define FW_TEXT_SIZE 2
#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels

#define OLED_RESET     -1 // Reset pin # (or -1 if sharing Arduino reset pin)
#define SCREEN_ADDRESS 0x3C ///< See datasheet for Address; 0x3D for 128x64, 0x3C for 128x32

#define STATE_CLOCK 0
#define STATE_MENU 1
#define STATE_WIFI_CONFIG 2
#define STATE_CALIBRATION 3
#define STATE_MEMORIES 4
#define STATE_UPDOWN 5
#define STATE_DEBUG_CONFIG 6

#define UP_RELAY_PIN 32
#define DOWN_RELAY_PIN 33

#define ENTER_BUTTON_PIN 34
#define BACK_BUTTON_PIN 35

#define ENCODER_PIN_A 18
#define ENCODER_PIN_B 19

#define ARRAY_SIZE(array) (sizeof(array)/sizeof((array)[0]))
#define SSD1306_NO_SPLASH
#define WDT_TIMEOUT 3

ESP32Encoder encoder;
WiFiManager wifiManager;
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
// String main_menu[] = {"WiFi Cfg.", "Calibr.", "Memories", "Clock", "Move", "Debug"};
String main_menu[] = {"WiFi Cfg.", "Move", "Debug"};

MenuInstance main_menu_instance(
    &display,
    &Serial,
    main_menu,
    ARRAY_SIZE(main_menu),
    "Menu:",
    ENTER_BUTTON_PIN,
    BACK_BUTTON_PIN
);

String up_down_menu[] = {"Up", "Down"};
MenuInstance up_down_menu_instance(
    &display,
    &Serial,
    up_down_menu,
    ARRAY_SIZE(up_down_menu),
    "Move:",
    ENTER_BUTTON_PIN,
    BACK_BUTTON_PIN
);

int current_state = 1;
int next_state = 1;
int retriesToConnectWifi = 10;
bool successConnectingWifi;
bool show_buttons_debug;
int last_wdt_reset = millis();

void draw_starting(void) {
    display.clearDisplay();
    display.setTextSize(FW_TEXT_SIZE);             // Draw 2X-scale text

    display.setTextColor(SSD1306_WHITE);        // Draw white text
    display.setCursor(0,0);             // Start at top-left corner
    display.println(F("WIFI"));
    display.println(F("STANDING"));
    display.println(F("DESK"));

    //  display.setTextColor(SSD1306_BLACK, SSD1306_WHITE); // Draw 'inverse' text

    display.display();
    delay(500);
}

void show_message(String input) {
    // display.clearDisplay();
    display.setCursor(0, 0);
    display.println(input);
    display.display();
}

void initialize_display() {
    if(!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
      Serial.println(F("SSD1306 allocation failed"));
      for(;;); // Don't proceed, loop forever
    }
    display.display();
    delay(200);
}

void setup() {
    // WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);

    // wifiManager.autoConnect("WIFI_STANDING_DESK", "PASSWORD");
    // Menu options:
    // Calibration
    // Memories
    // Wifi
    // Initialising the UI will init the display too.
    Serial.begin(115200);
    Serial.println();
    Serial.println();
    Serial.println("Starting Serial Port...");

    initialize_display();
    draw_starting();

    ESP32Encoder::useInternalWeakPullResistors=UP;
  	encoder.attachHalfQuad(ENCODER_PIN_B, ENCODER_PIN_A);

    pinMode(BACK_BUTTON_PIN, INPUT);
    pinMode(ENTER_BUTTON_PIN, INPUT);
    pinMode(DOWN_RELAY_PIN, OUTPUT);
    pinMode(UP_RELAY_PIN, OUTPUT);
    WiFi.mode(WIFI_STA);
    tryToConnectWifi();

    display.clearDisplay();
    config_wdt();
    config_api_endpoints();
}

void config_api_endpoints() {
    wifiManager.server->on("/up", [&]() {
        moveUpForMillis(500);
        wifiManager.server->send(200, "text/plain charset=utf-8", "Ok");
    });

    wifiManager.server->on("/down", [&]() {
        moveDownForMillis(500);
        wifiManager.server->send(200, "text/plain charset=utf-8", "Ok");
    });
}

void config_wdt() {
    esp_task_wdt_init(WDT_TIMEOUT, true); //enable panic so ESP32 restarts
    esp_task_wdt_add(NULL); //add current thread to WDT watch
}

void print_debug_info() {
    if (current_state == STATE_MENU) {
        return;
    }
    if (show_buttons_debug) {
        display.setCursor(50,50);
        display.setTextSize(1);
        display.println("B: " + String(digitalRead(BACK_BUTTON_PIN)) + " E: " + String(!digitalRead(ENTER_BUTTON_PIN)));
        display.display();
        display.setTextSize(FW_TEXT_SIZE);
    }
}

void moveUpForMillis(int duration) {
//     static int last_millis;
//     if (millist() - last_millis >)

//     last_millis = millis();
    moveUp();
    delay(duration);
    moveStop();
}

void moveDownForMillis(int duration) {
    moveDown();
    delay(duration);
    moveStop();
}

void moveUp() {
    digitalWrite(UP_RELAY_PIN, HIGH);
    digitalWrite(DOWN_RELAY_PIN, LOW);
}

void moveDown() {
    digitalWrite(DOWN_RELAY_PIN, HIGH);
    digitalWrite(UP_RELAY_PIN, LOW);
}

void moveStop() {
    digitalWrite(UP_RELAY_PIN, LOW);
    digitalWrite(DOWN_RELAY_PIN, LOW);
}

void handle_states_machine() {
    current_state = next_state;

    switch (current_state) {
        case STATE_MENU: {
            // Serial.println("Menu...");
            int selected_item;

            main_menu_instance.show();

            // Serial.println("printed_menu");

            selected_item = main_menu_instance.get_selection();

            if (selected_item == -1) next_state = STATE_CLOCK;

            // if (selected_item == 1) next_state = STATE_WIFI_CONFIG;
            // if (selected_item == 2) next_state = STATE_CALIBRATION;
            // if (selected_item == 3) next_state = STATE_MEMORIES;
            // if (selected_item == 4) next_state = STATE_CLOCK;
            // if (selected_item == 5) next_state = STATE_UPDOWN;
            // if (selected_item == 6) next_state = STATE_DEBUG_CONFIG;

            if (selected_item == 1) next_state = STATE_WIFI_CONFIG;
            if (selected_item == 2) next_state = STATE_UPDOWN;
            if (selected_item == 3) next_state = STATE_DEBUG_CONFIG;

            if (selected_item == 0) next_state = STATE_MENU;
        }
        break;
        case STATE_CLOCK: {
            Serial.println("Clock...");
            show_message("CLOCK!");
            set_next_state(STATE_CLOCK);
        }
        break;
        case STATE_WIFI_CONFIG: {
            Serial.println("Wifi...");
            display.setTextSize(1);
            String wifi_output = "WiFi Status:\n";
            if (WiFi.isConnected()) {
                wifi_output += "Connected to:\n" + String(WiFi.SSID());
                wifi_output += "\nIP Address:\n" + WiFi.localIP().toString();

            } else {
                wifi_output += "Not connected :(";
            }
            show_message(wifi_output);

            display.setTextSize(FW_TEXT_SIZE);
            set_next_state(STATE_WIFI_CONFIG);
        }
        break;
        case STATE_CALIBRATION: {
            Serial.println("Calibr...");
            show_message("CALIBR.!");
            set_next_state(STATE_CALIBRATION);
        }
        break;
        case STATE_MEMORIES: {
            Serial.println("Mem...");
            show_message("MEMORIES!");
            set_next_state(STATE_MEMORIES);
        }
        break;
        case STATE_UPDOWN: {
            Serial.println("Move...");
            // show_message("UP/DOWN!");

            int selected_direction;

            up_down_menu_instance.show();

            selected_direction = up_down_menu_instance.get_selection();

            if (!digitalRead(ENTER_BUTTON_PIN)) {
                if (selected_direction == 1) {
                    moveUp();
                } else if (selected_direction == 2) {
                    moveDown();
                }
            } else {
                moveStop();
            }

            set_next_state(STATE_UPDOWN);
        }
        break;
        case STATE_DEBUG_CONFIG: {
            if (!digitalRead(ENTER_BUTTON_PIN)) {
                show_buttons_debug = !show_buttons_debug;
            }
            show_message("Dbg: " + String(show_buttons_debug ? "ON ": "OFF"));
            set_next_state(STATE_DEBUG_CONFIG);
        }
        break;
    }

    if (next_state != current_state) {
        display.clearDisplay();
    }
}

void loop() {
    wifiManager.process();
    handle_states_machine();
    print_debug_info();
    int64_t encoder_count = encoder.getCount();
    main_menu_instance.process(encoder_count);
    up_down_menu_instance.process(encoder_count);
    reset_wdt();
}

void reset_wdt() {
    if (millis() - last_wdt_reset >= WDT_TIMEOUT / 2) {
        esp_task_wdt_reset();
        last_wdt_reset = millis();
    }
  }

void set_next_state(int state) {
    next_state = state;
    if (digitalRead(BACK_BUTTON_PIN) == HIGH) {
        next_state = STATE_MENU;
    }
}

void tryToConnectWifi() {
    wifiManager.setConfigPortalBlocking(false);
    wifiManager.startConfigPortal();
    successConnectingWifi = wifiManager.autoConnect("WIFI_STANDING_DESK","PASSWORD");
    if(!successConnectingWifi) {
        delay(250);
        retriesToConnectWifi--;
        // tryToConnectWifi();
    }
}
