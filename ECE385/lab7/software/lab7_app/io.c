#include "io.h"

/* ==================== KEY ==================== */

key_t *key_init(uint8_t key_num) {
    if (key_num == 0) // KEY[0] onboard is hardware system reset
        return NULL;
    key_t *key      = (key_t *)malloc(sizeof(key_t));
    key->key_state  = KEY_RELEASE;
    key->key_pio    = pio_init(KEY_BASE_ADDR); // It is okay to init multiple instance of pio
    key->key_offset = key_num;
    pio_clear_data(key->key_pio);
    return key;
}

key_state_e key_get_state(key_t *key) {
    if (key == NULL)
        return KEY_ERROR;
    uint8_t status = pio_get_data_bit(key->key_pio, key->key_offset);
    switch (key->key_state) {
        case KEY_RELEASE:
            if (status == 0) { // Key pressed, key is active low
                key->key_state = KEY_PRESSED;
                return KEY_PRESSED;
            }
            return KEY_RELEASE;
        case KEY_PRESSED:
            if (status == 1) {
                key->key_state = KEY_RELEASE;
                return KEY_RELEASE;
            }
            return KEY_PRESSING;
        default:
            return KEY_ERROR; // Never comes here
    }
}

/* ==================== LED ==================== */

led_t *led_init(uint32_t pio_addr, uint8_t led_num) {
    led_t *led   = (led_t *)malloc(sizeof(led_t));
    if (led == NULL)
        return NULL;
    led->led_pio = pio_init(pio_addr);
    led->led_num = led_num;
    pio_clear_data(led->led_pio);
    return led;
}

uint8_t led_on(led_t *led, uint8_t led_index) {
    if (led == NULL || led->led_num < led_index)
        return 0;
    return pio_set_data_bit(led->led_pio, led_index);
}

uint8_t led_off(led_t *led, uint8_t led_index) {
    if (led == NULL || led->led_num < led_index)
        return 0;
    return pio_clear_data_bit(led->led_pio, led_index);
}

uint8_t led_display(led_t *led, uint32_t data) {
    if (led == NULL)
        return 0;
    return pio_set_data(led->led_pio, data);
}

uint8_t led_clear(led_t *led) {
    if (led == NULL)
        return 0;
    return pio_set_data(led->led_pio, 0);
}

/* ==================== SWITCH ==================== */

sw_t *switch_init_group(uint8_t high_index, uint8_t low_index) {
    sw_t *sw   = (sw_t *)malloc(sizeof(sw_t));
    if (sw == NULL)
        return NULL;
    sw->sw_pio = pio_init(SWITCH_BASE_ADDR);
    sw->high   = high_index;
    sw->low    = low_index;
    return sw;
}

sw_t *switch_init(void) {
    return switch_init_group(SWITCH_NUM - 1, 0);
}

sw_t *switch_init_single(uint8_t index) {
    return switch_init_group(index, index);
}

uint32_t switch_get_group(sw_t *sw, uint8_t high_index, uint8_t low_index) {
    if (sw == NULL || high_index > sw->high || low_index < sw->low)
        return -1; // Since switch is only 18 bit max
    return (uint32_t)(((0x1 << (high_index - low_index + 1)) - 1) & (pio_get_data(sw->sw_pio) >> (sw->low + low_index)));
}

uint32_t switch_get(sw_t *sw) {
    if (sw == NULL)
        return -1;
    return (uint32_t)(((0x1 << (sw->high - sw->low + 1)) - 1) & (pio_get_data(sw->sw_pio) >> sw->low));
}

uint8_t switch_get_single(sw_t *sw, uint8_t index) {
    if (sw == NULL || index > sw->high || index < sw->low)
        return -1;
    return (uint32_t)(0x1 & (pio_get_data(sw->sw_pio) >> (sw->low + index)));
}
