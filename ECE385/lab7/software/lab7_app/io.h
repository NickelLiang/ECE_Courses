#ifndef IO_H
#define IO_H

#include "pio.h"
#include "utility.h"

/* ==================== KEY ==================== */
typedef enum {
    KEY_ERROR    = 0,
    KEY_PRESSED  = 1,
    KEY_PRESSING = -1,
    KEY_RELEASE  = -2,
} key_state_e;

typedef struct {
    pio_t       *key_pio;
    key_state_e key_state;
    uint8_t     key_offset;
} key_t;

/**
 * Initialize a key
 * @param  key_num Initialize which key onboard
 * @return         A key structure, NULL for error
 * @note   KEY[0] on board is hardware system reset
 */
key_t *key_init(uint8_t key_num);

/**
 * Return the key state of a key
 * @param  key A valid key struct
 * @return     State of that key, KEY_ERROR if key is NULL ptr
 */
key_state_e key_get_state(key_t *key);

#define PRESSED(key) (key_get_state(key) == KEY_PRESSED)

/* ==================== LED ==================== */
typedef struct {
    pio_t       *led_pio;
    uint8_t     led_num;
} led_t;

/**
 * Initialize LED group
 * @param  pio_addr PIO to init
 * @param  led_num  How many LEDs in this group
 * @return          LED structure, NULL for error
 */
led_t *led_init(uint32_t pio_addr, uint8_t led_num);

/**
 * Turn on LED at index
 * @param  led       A valid LED struct
 * @param  led_index Which LED in this group to turn on
 * @return           1 for success, 0 for error
 */
uint8_t led_on(led_t *led, uint8_t led_index);

/**
 * Turn off LED at index
 * @param  led       A valid LED struct
 * @param  led_index Which LED in this group to turn off
 * @return           1 for success, 0 for error
 */
uint8_t led_off(led_t *led, uint8_t led_index);

/**
 * Display a data on LED
 * @param  led  A valid LED struct
 * @param  data Data to be displayed
 * @return      1 for success, 0 for error
 */
uint8_t led_display(led_t *led, uint32_t data);

/**
 * Clear a group of LED
 * @param  led A valid LED struct
 * @return     1 for success, 0 for error
 */
uint8_t led_clear(led_t *led);

/* ==================== SWITCH ==================== */
typedef struct {
    pio_t   *sw_pio;
    uint8_t high;
    uint8_t low;
} sw_t;

/**
 * Init a switch group of SW[high_index:low_index]
 * @param  high_index High index of switch want to init
 * @param  low_index  Low index of switch want to init
 * @return            A switch structure
 */
sw_t *switch_init_group(uint8_t high_index, uint8_t low_index);

/**
 * Init all switch, from SWITCH_NUM-1 to 0
 * @return  A switch structure
 */
sw_t *switch_init(void);

/**
 * Init a single switch SW[index]
 * @param  index Index of switch want to init
 * @return       A switch structure, NULL for error
 */
sw_t *switch_init_single(uint8_t index);

/**
 * Get the value of the several switch of given switch structure
 * @param  sw         A valid switch structure
 * @param  high_index High index of switch among initialized switches
 * @param  low_index  Low index of switch among initialized switches
 * @return            The data on those switches, -1 for error
 * @example sw->high = 10, sw->low = 2, high_index = 3, low_index = 2,
 *          return SW[5:4]
 */
uint32_t switch_get_group(sw_t *sw, uint8_t high_index, uint8_t low_index);

/**
 * Get the value of all switch of given switch structure
 * @param  sw A valid switch structure
 * @return    The data on those switches, -1 for error
 * @example sw->high = 10, sw->low = 2, return SW[10:2]
 */
uint32_t switch_get(sw_t *sw);

/**
 * Get the value of a single switch in given switch structure
 * @param  sw    A valid switch structure
 * @param  index The index of switch among initialized switches
 * @return       The data on that switch, -1 for error
 * @example sw->high = 10, sw->low = 2, index = 2, return SW[4]
 */
uint8_t switch_get_single(sw_t *sw, uint8_t index);

#endif
