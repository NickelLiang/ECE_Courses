#ifndef UTILITY_H
#define UTILITY_H

#include "types.h"
#include "config.h"
#include <stdlib.h>

#include "priv/alt_busy_sleep.h"

/**
 * Delay t microsecond by execute adjusted busy loop
 * @param  t Microseconds to delay
 */
#define DELAY_US(t)     alt_busy_sleep(t)

/**
 * Delay t milisecond by execute adjusted busy loop
 * @param  t Milisecond to delay
 * @note  Since the cycle calculation is not accurate, in millisecond domain we need divide 3
 */
#define DELAY_MS(t)     alt_busy_sleep(1000*t/3) // Divide three to compensate large error

#endif
