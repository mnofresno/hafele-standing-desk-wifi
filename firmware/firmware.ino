#include <WiFiManager.h>
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <ESP32Encoder.h>

#define DEFAULT_TEXT_SIZE 2
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

#define ENTER_BUTTON_PIN 34
#define BACK_BUTTON_PIN 35

#define MENU_TOTAL_DISPLAYABLE_ITEMS 3
#define MENU_IDLE_TIME 10

#define ENCODER_PIN_A 18
#define ENCODER_PIN_B 19

#define ARRAY_SIZE(array) (sizeof(array)/sizeof((array)[0]))

ESP32Encoder encoder;
WiFiManager wifiManager;
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

int current_state = 1;
int next_state = 1;
int retriesToConnectWifi = 10;
bool successConnectingWifi;

void draw_starting(void) {
    display.clearDisplay();
    display.setTextSize(DEFAULT_TEXT_SIZE);             // Draw 2X-scale text

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

String pad_string(String input, String cPadWith, const unsigned char cMaxLen) {
	String strTemp = input;
	while (strTemp.length() < cMaxLen)
		strTemp += cPadWith;
	return strTemp;
}

void draw_menu_item(String item, bool selected = false) {
    Serial.println("Drawing menu item: " + item);
    if (selected) {
        set_highlighted_color();
    } else {
        set_normal_color();
    }
    display.println(pad_string(item, " ", 20 / DEFAULT_TEXT_SIZE));
    set_normal_color();
}

void set_highlighted_color() {
    display.setTextColor(SSD1306_BLACK, SSD1306_WHITE);
}

void set_normal_color() {
    display.setTextColor(SSD1306_WHITE, SSD1306_BLACK);
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
    //draw_menu();

    ESP32Encoder::useInternalWeakPullResistors=UP;
  	encoder.attachHalfQuad(ENCODER_PIN_B, ENCODER_PIN_A);

    pinMode(BACK_BUTTON_PIN, INPUT);
    pinMode(ENTER_BUTTON_PIN, INPUT);
    WiFi.mode(WIFI_STA);
    tryToConnectWifi();
}

void test_buttons() {
    // display.clearDisplay();
    display.setCursor(50,50);
    display.setTextSize(1);
    display.println("B: " + String(digitalRead(BACK_BUTTON_PIN)) + " E: " + String(digitalRead(ENTER_BUTTON_PIN)));
    display.display();
    display.setTextSize(DEFAULT_TEXT_SIZE);
}

void handle_states_machine() {
    current_state = next_state;

    switch (current_state) {
        case STATE_MENU: {
            Serial.println("Menu...");
            int selected_item;

            String main_menu[] = {"WiFi Conf.", "Calibr.", "Memories", "Clock", "Up/Down"};

            selected_item = draw_menu_and_get_current_item(main_menu, ARRAY_SIZE(main_menu));

            Serial.println("printed_menu");

            display.clearDisplay();

            if (selected_item == -1) next_state = STATE_CLOCK;

            if (selected_item == 1) next_state = STATE_WIFI_CONFIG;
            if (selected_item == 2) next_state = STATE_CALIBRATION;
            if (selected_item == 3) next_state = STATE_MEMORIES;
            if (selected_item == 4) next_state = STATE_CLOCK;
            if (selected_item == 5) next_state = STATE_UPDOWN;
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

            display.setTextSize(DEFAULT_TEXT_SIZE);
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
            Serial.println("UP/DOWN...");
            show_message("UP/DOWN!");
            set_next_state(STATE_UPDOWN);
        }
        break;
    }
}

void loop() {
    wifiManager.process();
    handle_states_machine();
    test_buttons();
}

void set_next_state(int state) {
    next_state = state;
    if (digitalRead(BACK_BUTTON_PIN) == HIGH) {
        next_state = STATE_MENU;
    }
}

void show_menu_header() {
    display.setCursor(0,0);             // Start at top-left corner
    show_message("Menu:");
}

void show_menu_items(String *arrayMenu,  int total_menu_size, int extra_option = 0, int selected_option = 1) {
    show_menu_header();
    for(int x = extra_option; x < total_menu_size && x <= (MENU_TOTAL_DISPLAYABLE_ITEMS - 1 + extra_option) ; x++) {
        draw_menu_item(arrayMenu[x], (selected_option - 1) == x );
    }
    display.display();
}

int draw_menu_and_get_current_item(String *arrayMenu, int total_menu_size) {
    display.clearDisplay();

    //Vamos a marcar en que tiempo se hizo cualquier cambio y si se hizo un cambio hace muy poco tiempo y se pulso, ese cambio le damos por malo. ok?
    //Pintamos el cursor y marcamos la primera selected_option

    float selected_option = 1;  //del 1 al 1.75 selected_option 1  //Del 2  al 2.75 selected_option 2
    int extra_option = 0;
    float increment = 0.5;

    show_menu_items(arrayMenu, total_menu_size);

    delay(500);

    int64_t current_dial_position = 0;
    int64_t last_dial_position = 0;

    unsigned long increment_change_time = 0;
    unsigned long decrement_change_time = 0;

    while (digitalRead(ENTER_BUTTON_PIN) == LOW) {
        current_dial_position = encoder.getCount();

        if (current_dial_position != last_dial_position) {
            if (current_dial_position < last_dial_position) {
                if (selected_option < total_menu_size) {
                    selected_option += increment;
                    increment_change_time = millis();
                }
            } else if (current_dial_position > last_dial_position) {
                if(selected_option > 1) {
                    selected_option -= increment;
                    decrement_change_time = millis();
                }
            }

            if(selected_option < 1 + extra_option)
                extra_option--;
            if(selected_option > MENU_TOTAL_DISPLAYABLE_ITEMS + extra_option)
                extra_option++;

            show_menu_items(arrayMenu, total_menu_size, extra_option, selected_option);
        }
        if(digitalRead(BACK_BUTTON_PIN) == HIGH) {
            return -1;  //break
        }

        last_dial_position = current_dial_position;
    }

    if (millis() - increment_change_time < 250)
        selected_option -= increment;
    else if(millis() - decrement_change_time < 250)
        selected_option += increment;

    return selected_option;
}

void tryToConnectWifi() {
    wifiManager.setConfigPortalBlocking(false);
    wifiManager.startConfigPortal();
    successConnectingWifi = wifiManager.autoConnect("WIFI_STANDING_DESK","PASSWORD");
    if(!successConnectingWifi) {
        delay(250);
        retriesToConnectWifi--;
        tryToConnectWifi();
    }
}
