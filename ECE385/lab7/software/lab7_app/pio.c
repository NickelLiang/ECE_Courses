#include "pio.h"

pio_t *pio_init(uint32_t base_addr) {
    pio_t *pio = (pio_t *)base_addr;
    return pio;
}

uint32_t pio_get_base_addr(pio_t *pio) {
    return (uint32_t)&pio;
}

uint32_t pio_get_direction(pio_t *pio) {
    return pio->direction;
}

uint32_t pio_get_interrupt_mask(pio_t *pio) {
    return pio->interrupt_mask;
}

uint32_t pio_get_edge_capture(pio_t *pio) {
    return pio->edge_capture;
}

uint32_t pio_get_data(pio_t *pio) {
    return pio->data;
}

uint8_t pio_get_data_bit(pio_t *pio, uint8_t offset) {
    return (pio->data & (0x1 << offset)) != 0;
}

uint8_t pio_set_data(pio_t *pio, uint32_t data) {
    if (pio == NULL)
        return 0;
    pio->data = data;
    return 1;
}

uint8_t pio_set_data_bit(pio_t *pio, uint8_t offset) {
    if (pio == NULL)
        return 0;
    pio->data |= (0x1 << offset);
    return 1;
}

uint8_t pio_clear_data(pio_t *pio) {
    if (pio == NULL)
        return 0;
    pio->data = 0;
    return 1;
}

uint8_t pio_clear_data_bit(pio_t *pio, uint8_t offset) {
    if (pio == NULL)
        return 0;
    pio->data &= ~(0x1 << offset);
    return 1;
}
