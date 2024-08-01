#include "DisplayHandler.h"

DisplayHandler::DisplayHandler(Adafruit_SSD1306 *display) {
    _display = display;
}

void DisplayHandler::show_message(String input, bool reset_cursor) {
    if (reset_cursor) {
        _display->setCursor(0, 0);
    }
    _display->println(input);
    _display->display();
}

void DisplayHandler::println_with_pad(String input, int length) {
    _display->println(pad_string(input, " ", length));
}

void DisplayHandler::print_with_pad(String input, int length) {
    _display->print(pad_string(input, " ", length));
}

String DisplayHandler::pad_string(String input, String cPadWith, const unsigned char cMaxLen) {
	String strTemp = input;
	while (strTemp.length() < cMaxLen)
		strTemp += cPadWith;
	return strTemp;
}

void DisplayHandler::draw_starting(String version_string) {
    initialize();

    _display->clearDisplay();
    _display->setTextSize(FW_TEXT_SIZE_LARGE);

    _display->setTextColor(SSD1306_WHITE);        // Draw white text
    _display->setCursor(0,0);             // Start at top-left corner
    _display->println(F("WIFI"));
    _display->println(F("STANDING"));
    _display->println(F("DESK"));
    _display->setTextSize(FW_TEXT_SIZE_SMALL);
    _display->println(pad_string("", "-", 20));
    _display->println(version_string);
    _display->setTextSize(FW_TEXT_SIZE_LARGE);

    _display->display();
    delay(1000);
    _display->clearDisplay();
}

void DisplayHandler::initialize() {
    if(!_display->begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
      Serial.println(F("SSD1306 allocation failed"));
      for(;;);
    }
    _display->display();
    delay(200);
}

Adafruit_SSD1306 * DisplayHandler::display() {
    return _display;
}

void DisplayHandler::print_full_screen_with_title(String title, String body) {
    static int last_title_length = 0;
    static int last_body_length = 0;

    _display->setCursor(0, 0);

    _display->setTextSize(FW_TEXT_SIZE_LARGE);
    show_message(pad_string(title, " ", last_title_length));
    _display->setTextSize(FW_TEXT_SIZE_SMALL);
    show_message(pad_string(body, " ", last_body_length), false);

    last_title_length = title.length();
    last_body_length = body.length();
}

void DisplayHandler::anti_flickering(std::function<void()> callback, int millis_between_calls) {
    unsigned long current_millis = millis();
    static unsigned long last_time_update = current_millis;
    if (current_millis - last_time_update > millis_between_calls) {
        callback();
        last_time_update = current_millis;
    }
}
