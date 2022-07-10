#include "MenuInstance.h"

MenuInstance::MenuInstance(Adafruit_SSD1306 *display, String *arrayMenu, unsigned int total_menu_size) {
    _display = display;
    _arrayMenu = arrayMenu;
    _total_menu_size = total_menu_size;
}

MenuInstance::MenuInstance(Adafruit_SSD1306 *display, HardwareSerial *debug_print, String *arrayMenu, unsigned int total_menu_size) {
    _display = display;
    _debug_print = debug_print;
    _arrayMenu = arrayMenu;
    _total_menu_size = total_menu_size;
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

    if (digitalRead(ENTER_BUTTON_PIN) == LOW) {
        if (current_dial_position != last_dial_position) {
            if (current_dial_position < last_dial_position) {
                if (selected_option < _total_menu_size) {
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

            show_menu_items();

        }
        if(digitalRead(BACK_BUTTON_PIN) == HIGH) {
            selected_option = -1;
            return;  //break
        }

    // } else {
    //     if (millis() - increment_change_time < 250)
    //         selected_option -= increment;
    //     else if(millis() - decrement_change_time < 250)
    //         selected_option += increment;
    }

    last_dial_position = current_dial_position;
}

void MenuInstance::show_message(String input) {
    _display->setCursor(0, 0);
    _display->println(input);
    _display->display();
}

void MenuInstance::show_menu_header() {
    _display->setCursor(0,0);             // Start at top-left corner
    show_message(pad_string("Menu:", " ", 20 / DEFAULT_TEXT_SIZE));
}

void MenuInstance::show_menu_items() {
    show_menu_header();
    for(int x = extra_option; x < _total_menu_size && x <= (MENU_TOTAL_DISPLAYABLE_ITEMS - 1 + extra_option) ; x++) {
        draw_menu_item(_arrayMenu[x], ((int)selected_option - 1) == x );
    }
    _display->display();
}


String MenuInstance::pad_string(String input, String cPadWith, const unsigned char cMaxLen) {
	String strTemp = input;
	while (strTemp.length() < cMaxLen)
		strTemp += cPadWith;
	return strTemp;
}

void MenuInstance::draw_menu_item(String item, bool selected) {
    if (_debug_print != NULL) {
        Serial.println("Drawing menu item: " + item);
    }
    if (selected) {
        set_highlighted_color();
    } else {
        set_normal_color();
    }
    _display->println(pad_string(item, " ", 20 / DEFAULT_TEXT_SIZE));
    set_normal_color();
}

void MenuInstance::set_highlighted_color() {
    _display->setTextColor(SSD1306_BLACK, SSD1306_WHITE);
}

void MenuInstance::set_normal_color() {
    _display->setTextColor(SSD1306_WHITE, SSD1306_BLACK);
}

int MenuInstance::get_selection() {
    if (digitalRead(ENTER_BUTTON_PIN) == HIGH) {
        return selected_option;
    }
    return 0;
}
