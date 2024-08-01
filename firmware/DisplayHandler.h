#ifndef DisplayHandler_h
#define DisplayHandler_h

#include <Adafruit_SSD1306.h>

#define SCREEN_ADDRESS 0x3C ///< See datasheet for Address; 0x3D for 128x64, 0x3C for 128x32

#define FW_TEXT_SIZE_SMALL 1
#define FW_TEXT_SIZE_LARGE 2
#define DEFAULT_TEXT_SIZE 2
#define PADDING 20 / DEFAULT_TEXT_SIZE

class DisplayHandler {
    private:
        Adafruit_SSD1306 *_display;
        void initialize();
        String pad_string(String input, String cPadWith, const unsigned char cMaxLen);
    public:
        DisplayHandler(Adafruit_SSD1306 *display);
        void show_message(String input, bool reset_cursor = true);
        void draw_starting(String version_string);
        Adafruit_SSD1306* display();
        void println_with_pad(String input, int length = 20);
        void print_with_pad(String input, int length = 20);
        void print_full_screen_with_title(String title, String body);
        void anti_flickering(std::function<void()> callback, int millis_between_calls = 180);
};

#endif
