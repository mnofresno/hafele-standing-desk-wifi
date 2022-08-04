#ifndef MenuInstance_h
#define MenuInstance_h

#include <Adafruit_SSD1306.h>
#include <HardwareSerial.h>
#include <string.h>
#include "DisplayHandler.h"

#define DEFAULT_TEXT_SIZE 2
#define PADDING 20 / DEFAULT_TEXT_SIZE
#define MENU_TOTAL_DISPLAYABLE_ITEMS 6 / DEFAULT_TEXT_SIZE
#define MENU_ITEM_GO_BACK -1

struct MenuItem {
    int index;
    char title[20];
};

class MenuInstance {
    private:
        Adafruit_SSD1306 *_display;
        DisplayHandler *_display_handler;
        HardwareSerial *_debug_print;
        MenuItem *_menu_items;
        int _total_menu_size;
        int64_t current_dial_position = 0;
        int64_t last_dial_position = 0;
        float selected_option = 1;  // From 1 to 1.75 selected_option is 1 -> From 2 to 2.75 selected_option is 2
        int extra_option = 0;
        String _title;
        uint8_t _enter_button_pin;
        uint8_t _back_button_pin;
        void show_menu_items();
        void show_menu_header();
        void draw_menu_item(MenuItem item, bool selected = false);
        void set_highlighted_color();
        void set_normal_color();
        bool is_item_selected(int current_item);
        void assert_menu_index(int array_index);

    public:
        MenuInstance(
            DisplayHandler *display_handler,
            HardwareSerial *debug_print,
            MenuItem *menu_items,
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
