#ifndef MenuInstance_h
#define MenuInstance_h

#include <Adafruit_SSD1306.h>
#include <string.h>
#include "DisplayHandler.h"
#include "ButtonsHandler.h"

#define DEFAULT_MENU_SIZE 2
#define SUBTITLE_SIZE 1
#define MAX_DISPLAYABLE_ITEMS 6
#define MENU_ITEM_GO_BACK -1
#define DIAL_INCREMENT 0.5

struct MenuItem {
    int index;
    char title[20];
};

class MenuInstance {
    private:
        Adafruit_SSD1306 *_display;
        DisplayHandler *_display_handler;
        MenuItem *_menu_items;
        int _total_menu_size;
        int _font_size = DEFAULT_MENU_SIZE;
        int64_t current_dial_position = 0;
        int64_t last_dial_position = 0;
        float selected_option = 1;  // From 1 to 1.75 selected_option is 1 -> From 2 to 2.75 selected_option is 2
        int extra_option = 0;
        String _title;
        String _subtitle;
        ButtonsHandler * _buttons_handler;
        void show_menu_items();
        void do_show_menu_items();
        void show_menu_header();
        void draw_menu_item(MenuItem item, bool selected = false);
        void set_highlighted_color();
        void set_normal_color();
        bool is_item_selected(int current_item);
        void assert_menu_index(int array_index);
        int totalDisplayableItems();
        int padding(int font_size);
        void assert_extra_option();

    public:
        MenuInstance(
            DisplayHandler *display_handler,
            MenuItem *menu_items,
            unsigned int total_menu_size,
            String title,
            ButtonsHandler * buttons_handler
        );
        void updatePosition(int64_t dialPosition);
        void show();
        int get_selection();
        void setTitle(String title, String subtitle = "");
        void setItems(MenuItem *menu_items);
        void setFontSize(int size);
};
#endif
