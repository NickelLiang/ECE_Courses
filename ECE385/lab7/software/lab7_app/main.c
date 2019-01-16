#include "types.h"
#include "io.h"

int main() {
    // test();
    led_t *led_r = led_init(LEDR_BASE_ADDR, LEDR_NUM);
    led_t *led_g = led_init(LEDG_BASE_ADDR, LEDG_NUM);
    sw_t *sw_7_0 = switch_init_group(7, 0);
    key_t *reset = key_init(1);
    key_t *accum = key_init(2);

    uint16_t input = 0;
    uint16_t sum = 0;
    led_display(led_r, input);
    led_display(led_g, sum);

    while (1) {
        input = switch_get(sw_7_0);
        if (PRESSED(accum)) {
            if (sum + input > 255)
                sum += input - 256;
            else
                sum += input;
        }
        if (PRESSED(reset)) {
            sum = 0;
        }
        led_display(led_r, input);
        led_display(led_g, sum);
    }
    return 1;
}

void test(void) {
    // key_t *key_1 = key_init(1);
    // key_t *key_2 = key_init(2);
    // key_t *key_3 = key_init(3);
    // led_t *led_g = led_init(LEDG_BASE_ADDR, LEDG_NUM);
    // led_t *led_r = led_init(LEDR_BASE_ADDR, LEDR_NUM);
    // sw_t *sw_all = switch_init();
    // sw_t *sw_10_2 = switch_init_group(10, 2);
    // sw_t *sw_16 = switch_init_single(16);
    //
    // uint8_t key_count = 0;
    // uint32_t sw_data = 0;
    //
    // led_clear(led_g);
    // led_clear(led_r);

    while (1) {
        // Test 1 LED
        // for (size_t i = 0; i < LEDG_NUM; i++) {
        //     led_on(led_g, i);
        //     DELAY_MS(25);
        // }
        // for (size_t i = 0; i < LEDR_NUM; i++) {
        //     led_on(led_r, i);
        //     DELAY_MS(25);
        // }
        // for (size_t i = 0; i < LEDG_NUM; i++) {
        //     led_off(led_g, i);
        //     DELAY_MS(25);
        // }
        // for (size_t i = 0; i < LEDR_NUM; i++) {
        //     led_off(led_r, i);
        //     DELAY_MS(25);
        // }

        // Test 2 LED
        // led_display(led_g, 0xFF);
        // led_display(led_r, 0x3FFFF);
        // DELAY_MS(1000);
        // led_display(led_g, 0xAA);
        // led_display(led_r, 0x2AAAA);
        // DELAY_MS(1000);
        // led_display(led_g, 0x55);
        // led_display(led_r, 0x15555);
        // DELAY_MS(1000);
        // led_display(led_g, 0x00);
        // led_display(led_r, 0x00000);
        // DELAY_MS(1000);

        // Test 3 KEY + LED
        // if (PRESSED(key_1)) {
        //     led_display(led_g, 0xFF);
        //     led_display(led_r, 0x3FFFF);
        // } else if (PRESSED(key_2)) {
        //     led_display(led_g, 0xAA);
        //     led_display(led_r, 0x2AAAA);
        // } else if (PRESSED(key_3)) {
        //     led_display(led_g, 0x55);
        //     led_display(led_r, 0x15555);
        // }

        // Test 4 KEY + LED
        // if (PRESSED(key_1)) {
        //     key_count++;
        // } else if (PRESSED(key_2)) {
        //     key_count++;
        // } else if (PRESSED(key_3)) {
        //     key_count++;
        // }
        // led_display(led_g, key_count);

        // Test 5 SWITCH + LED
        // led_display(led_r, switch_get(sw_all));

        // Test 6 SWITCH + LED, set SW[4] will lit LEDR[0] and LEDR[17]
        // set SW[5] will lit LEDR[1], set SW[16] will lit LEDG[0]
        // led_display(led_r, switch_get_group(sw_10_2, 3, 2));
        // led_display(led_r, switch_get_single(sw_10_2, 2) << 17);
        // led_display(led_g, switch_get(sw_16));
    }
}
