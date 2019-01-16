#ifndef CONFIG_H
#define CONFIG_H

// Base Address
#define ONCHIP_MEM_BASE_ADDR    0x00000000
#define ONCHIP_MEM_CELL_ADDR    0x0000000F

#define LEDG_BASE_ADDR          0x00000020
#define LEDG_CELL_ADDR          0x0000002F
#define LEDG_NUM                8

#define SWITCH_BASE_ADDR        0x00000030
#define SWITCH_CELL_ADDR        0x0000003F
#define SWITCH_NUM              18

#define KEY_BASE_ADDR           0x00000040
#define KEY_CELL_ADDR           0x0000004F
#define KEY_NUM                 4

#define LEDR_BASE_ADDR          0x00000050
#define LEDR_CELL_ADDR          0x0000005F
#define LEDR_NUM                18

#define SDRAM_PLL_BASE_ADDR     0x00000060
#define SDRAM_PLL_CELL_ADDR     0x0000006F

#define SYSID_BASE_ADDR         0x00000078
#define SYSID_CELL_ADDR         0x0000007F

#define NIOS_BASE_ADDR          0x00001000
#define NIOS_CELL_ADDR          0x000017FF

#define SDRAM_BASE_ADDR         0x10000000
#define SDRAM_CELL_ADDR         0x17FFFFFF

#endif
