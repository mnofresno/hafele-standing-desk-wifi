#ifndef MenuInstance_h
#define MenuInstance_h

#include <Adafruit_SSD1306.h>
#include <HardwareSerial.h>

#define MENU_TOTAL_DISPLAYABLE_ITEMS 3
#define DEFAULT_TEXT_SIZE 2

class MenuInstance {
    private:
        Adafruit_SSD1306 *_display;
        HardwareSerial *_debug_print;
        String *_arrayMenu;
        int _total_menu_size;
        int64_t current_dial_position = 0;
        int64_t last_dial_position = 0;
        unsigned long increment_change_time = 0;
        unsigned long last_render_time = 0;
        unsigned long decrement_change_time = 0;
        float selected_option = 0;  // From 1 to 1.75 selected_option is 1 -> From 2 to 2.75 selected_option is 2
        int extra_option = 0;
        String _title;
        uint8_t _enter_button_pin;
        uint8_t _back_button_pin;
        void show_menu_items();
        void show_menu_header();
        void draw_menu_item(String item, bool selected = false);
        String pad_string(String input, String cPadWith, const unsigned char cMaxLen);
        void set_highlighted_color();
        void set_normal_color();
        void show_message(String input);

    public:
        MenuInstance(
            Adafruit_SSD1306 *display,
            HardwareSerial *debug_print,
            String *arrayMenu,
            unsigned int total_menu_size,
            String title,
            uint8_t enter_button_pin,
            uint8_t back_button_pin
        );
        void process(int64_t dialPosition);
        void show();
        int get_selection();

};
#endif
