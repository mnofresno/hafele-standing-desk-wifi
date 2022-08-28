#include "MenuInstance.h"

MenuInstance::MenuInstance(
    DisplayHandler *display_handler,
    MenuItem *menu_items,
    unsigned int total_menu_size,
    String title,
    ButtonsHandler * buttons_handler
) {
    _display_handler = display_handler;
    _display = _display_handler->display();
    _menu_items = menu_items;
    _total_menu_size = total_menu_size;
    _title = title;
    _buttons_handler = buttons_handler;
}

void MenuInstance::process(int64_t dialPosition) {
    current_dial_position = dialPosition;
}

void MenuInstance::show() {
    float increment = 0.5;

    show_menu_items();

    if (!_buttons_handler->readEnterButton()) {
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
            if(selected_option > totalDisplayableItems() + extra_option)
                extra_option++;

            show_menu_items();

        }
        if(_buttons_handler->readBackButton()) {
            selected_option = MENU_ITEM_GO_BACK;
            return;
        }
    }

    last_dial_position = current_dial_position;
}

void MenuInstance::show_menu_header() {
    _display->setTextSize(_font_size);
    _display->setCursor(0,0);             // Start at top-left corner
    _display_handler->println_with_pad(_title, PADDING);
}

void MenuInstance::show_menu_items() {
    _display_handler->anti_flickering([&]() {
        show_menu_header();
        for(int x = extra_option; x < _total_menu_size && x <= (totalDisplayableItems() - 1 + extra_option); x++) {
            draw_menu_item(_menu_items[x], is_item_selected(x));
            assert_menu_index(x);
        }
        _display->display();
    });
}

bool MenuInstance::is_item_selected(int current_item) {
    return ((int)selected_option - 1) == current_item;
}

void MenuInstance::draw_menu_item(MenuItem item, bool selected) {
    String title = item.title;
    if (selected) {
        set_highlighted_color();
    } else {
        set_normal_color();
    }
    _display_handler->println_with_pad(title, PADDING);
    set_normal_color();
}

void MenuInstance::set_highlighted_color() {
    _display->setTextColor(SSD1306_BLACK, SSD1306_WHITE);
}

void MenuInstance::set_normal_color() {
    _display->setTextColor(SSD1306_WHITE, SSD1306_BLACK);
}

int MenuInstance::get_selection() {
    if (_buttons_handler->readEnterButton()) {
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

void MenuInstance::setTitle(String title) {
    _title = title;
}

void MenuInstance::setItems(MenuItem *menu_items) {
    _menu_items = menu_items;
}

void MenuInstance::setFontSize(int size) {
    _font_size = size;
}

int MenuInstance::totalDisplayableItems() {
    return MAX_DISPLAYABLE_ITEMS / _font_size;
}
