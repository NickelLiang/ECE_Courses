#ifndef PIO_H
#define PIO_H

#include "utility.h"

typedef struct {
    volatile uint32_t data;
    volatile uint32_t direction;
    volatile uint32_t interrupt_mask;
    volatile uint32_t edge_capture;
} pio_t;

/**
 * Initialize a instance
 * @param  base_addr Base address of PIO
 * @return           Initialized PIO struct
 */
pio_t *pio_init(uint32_t base_addr);

/**
 * Get the base address of a PIO
 * @param  pio A valid PIO structure
 * @return     Base address of given PIO
 */
uint32_t pio_get_base_addr(pio_t *pio);

/**
 * Get the direction of a PIO
 * @param  pio A valid PIO structure
 * @return     Direction of given PIO
 */
uint32_t pio_get_direction(pio_t *pio);

/**
 * Get the interrupt mask of a PIO
 * @param  pio A valid PIO structure
 * @return     Interrupt mask of given PIO
 */
uint32_t pio_get_interrupt_mask(pio_t *pio);

/**
 * Get the edge capture of a PIO
 * @param  pio A valid PIO structure
 * @return     Edge capture of given PIO
 */
uint32_t pio_get_interrupt_mask(pio_t *pio);

/**
 * Get data section of PIO
 * @param  pio  A valid PIO structure
 * @return      Data of given PIO
 */
uint32_t pio_get_data(pio_t *pio);

/**
 * Get a bit of data in PIO
 * @param  pio    A valid PIO structure
 * @param  offset Offset of the bit you want to get
 * @return        Content of the bit you want to get
 */
uint8_t pio_get_data_bit(pio_t *pio, uint8_t offset);

/**
 * Set data section of PIO
 * @param  pio  A valid PIO structure
 * @param  data 32-bit Data you want to write
 * @return      1 for success, 0 for error
 */
uint8_t pio_set_data(pio_t *pio, uint32_t data);

/**
 * Set a bit of data in PIO
 * @param  pio    A valid PIO structure
 * @param  offset Offset of the bit you want to set
 * @return        1 for success, 0 for error
 */
uint8_t pio_set_data_bit(pio_t *pio, uint8_t offset);

/**
 * Celar data section of PIO
 * @param  pio A valid PIO structure
 * @return     1 for success, 0 for error
 */
uint8_t pio_clear_data(pio_t *pio);

/**
 * Clear a bit of data in PIO
 * @param  pio    A valid PIO structure
 * @param  offset Offset of the bit you want to clear
 * @return        1 for success, 0 for error
 */
uint8_t pio_clear_data_bit(pio_t *pio, uint8_t offset);

#endif
