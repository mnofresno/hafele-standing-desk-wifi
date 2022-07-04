#include <WiFiManager.h>
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <ESP32Encoder.h>

#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels

#define OLED_RESET     -1 // Reset pin # (or -1 if sharing Arduino reset pin)
#define SCREEN_ADDRESS 0x3C ///< See datasheet for Address; 0x3D for 128x64, 0x3C for 128x32

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

#define STATE_CLOCK = 0
#define STATE_MENU = 1
#define STATE_MENU_WIFI = 2
#define STATE_MENU_CALIBRATION = 3
#define STATE_MENU_MEMORIES = 4

#define ENCODER_PIN_A 18
#define ENCODER_PIN_B 19

ESP32Encoder encoder;
WiFiManager wifiManager;

void draw_starting(void) {
    display.clearDisplay();
    display.setTextSize(1.8);             // Draw 2X-scale text
    
    display.setTextColor(SSD1306_WHITE);        // Draw white text
    display.setCursor(0,0);             // Start at top-left corner
    display.println(F("WIFI STANDING DESK"));

    //  display.setTextColor(SSD1306_BLACK, SSD1306_WHITE); // Draw 'inverse' text
  
    display.display();
    delay(200);
}

void draw_menu() {
    display.clearDisplay();
    display.setCursor(0,0);
    display.println(F("MENU:"));
    display.println(F("WiFi Conf."));
    display.println(F("Calibration"));
    display.println(F("Memories"));
    display.display();
}

void initialize_display() {
    if(!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
      Serial.println(F("SSD1306 allocation failed"));
      for(;;); // Don't proceed, loop forever
    }
  
    // Show initial display buffer contents on the screen --
    // the library initializes this with an Adafruit splash screen.
    display.display();
    delay(200); // Pause for 2 seconds
  
    // Clear the buffer
    display.clearDisplay();
  
    // Draw a single pixel in white
    // display.drawPixel(10, 10, SSD1306_WHITE);
  
    // Show the display buffer on the screen. You MUST call display() after
    // drawing commands to make them visible on screen!
    display.display();
    delay(200);
    // display.display() is NOT necessary after every single drawing command,
    // unless that's what you want...rather, you can batch up a bunch of
    // drawing operations and then update the screen all at once by calling
    // display.display(). These examples demonstrate both approaches...

}

void setup() {
    wifiManager.autoConnect("WIFI_STANDING_DESK", "PASSWORD");
    // Menu options:
    // Calibration
    // Memories
    // Wifi
    // Initialising the UI will init the display too.
    Serial.begin(115200);
    Serial.println();
    Serial.println();
    Serial.println("Prueba...");

    initialize_display();
    draw_starting();
    draw_menu();
    
    ESP32Encoder::useInternalWeakPullResistors=UP;
  	encoder.attachHalfQuad(ENCODER_PIN_A, ENCODER_PIN_B);
}


void loop() {
    Serial.println("Encoder count = " + String((int32_t)encoder.getCount()));
	  delay(100);
    draw_menu();
}
