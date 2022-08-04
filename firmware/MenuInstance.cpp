#include "MenuInstance.h"

MenuInstance::MenuInstance(
    Adafruit_SSD1306 *display,
    HardwareSerial *debug_print,
    MenuItem *menu_items,
    unsigned int total_menu_size,
    String title,
    uint8_t enter_button_pin,
    uint8_t back_button_pin
) {
    _display = display;
    _debug_print = debug_print;
    _menu_items = menu_items;
    _total_menu_size = total_menu_size;
    _title = title;
    _enter_button_pin = enter_button_pin;
    _back_button_pin = back_button_pin;
}

void MenuInstance::process(int64_t dialPosition) {
    current_dial_position = dialPosition;
}

void MenuInstance::show() {
    float increment = 0.5;

    if (millis() - last_render_time  < 250) {
        return;
    }
    last_render_time = millis();
    show_menu_items();

    if (!digitalRead(_enter_button_pin) == LOW) {
        if (current_dial_position != last_dial_position) {
            if (current_dial_position < last_dial_position) {
                if (selected_option < _total_menu_size) {
                    selected_option += increment;
                }
            } else if (current_dial_position > last_dial_position) {
                if(selected_option > 1) {
                    selected_option -= increment;
                }
            }

            if(selected_option < 1 + extra_option && extra_option > 0)
                extra_option--;
            if(selected_option > MENU_TOTAL_DISPLAYABLE_ITEMS + extra_option)
                extra_option++;

            show_menu_items();

        }
        if(digitalRead(_back_button_pin) == HIGH) {
            selected_option = MENU_ITEM_GO_BACK;
            return;
        }
    }

    last_dial_position = current_dial_position;
}

void MenuInstance::show_menu_header() {
    _display->setTextSize(DEFAULT_TEXT_SIZE);
    _display->setCursor(0,0);             // Start at top-left corner
    _display->println(pad_string(_title, " ", PADDING));
}

void MenuInstance::show_menu_items() {
    show_menu_header();
    for(int x = extra_option; x < _total_menu_size && x <= (MENU_TOTAL_DISPLAYABLE_ITEMS - 1 + extra_option); x++) {
        draw_menu_item(_menu_items[x], is_item_selected(x));
        assert_menu_index(x);
    }
    _display->display();
}

bool MenuInstance::is_item_selected(int current_item) {
    return ((int)selected_option - 1) == current_item;
}

String MenuInstance::pad_string(String input, String cPadWith, const unsigned char cMaxLen) {
	String strTemp = input;
	while (strTemp.length() < cMaxLen)
		strTemp += cPadWith;
	return strTemp;
}

void MenuInstance::draw_menu_item(MenuItem item, bool selected) {
    String title = item.title;
    if (_debug_print != NULL) {
        _debug_print->println("Drawing menu item: " + title);
    }
    if (selected) {
        set_highlighted_color();
    } else {
        set_normal_color();
    }
    _display->println(pad_string(title, " ", PADDING));
    set_normal_color();
}

void MenuInstance::set_highlighted_color() {
    _display->setTextColor(SSD1306_BLACK, SSD1306_WHITE);
}

void MenuInstance::set_normal_color() {
    _display->setTextColor(SSD1306_WHITE, SSD1306_BLACK);
}

int MenuInstance::get_selection() {
    if (!digitalRead(_enter_button_pin) == HIGH) {
        int array_index = (int)selected_option - 1;
        assert_menu_index(array_index);
        return _menu_items[array_index].index;
    }
    return 0;
}

void MenuInstance::assert_menu_index(int array_index) {
    assert(array_index >= 0);
    assert(array_index < _total_menu_size);
}
