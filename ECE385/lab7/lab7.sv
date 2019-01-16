module lab7(
    input         CLOCK_50,
    input  [3:0]  KEY,
    output [7:0]  LEDG,
    output [17:0] LEDR,
    input  [17:0] SW,
    output [12:0] DRAM_ADDR,
    output [1:0]  DRAM_BA,
    output        DRAM_CAS_N,
    output        DRAM_CKE,
    output        DRAM_CS_N,
    inout  [31:0] DRAM_DQ,
    output  [3:0] DRAM_DQM,
    output        DRAM_RAS_N,
    output        DRAM_WE_N,
    output        DRAM_CLK
    );

    logic [17:0] SW_Sync;
    logic [3:0] KEY_Sync;

    lab7_soc m_lab7_soc (
        .clk_clk(CLOCK_50),
        .key_wire_export(KEY_Sync),
        .led_red_wire_export(LEDR),
        .led_wire_export(LEDG),
        .reset_reset_n(KEY_Sync[0]),
        .switch_wire_export(SW_Sync),
        .sdram_wire_addr(DRAM_ADDR),    //  sdram_wire.addr
        .sdram_wire_ba(DRAM_BA),        //  .ba
        .sdram_wire_cas_n(DRAM_CAS_N),  //  .cas_n
        .sdram_wire_cke(DRAM_CKE),      //  .cke
        .sdram_wire_cs_n(DRAM_CS_N),    //  .cs_n
        .sdram_wire_dq(DRAM_DQ),        //  .dq
        .sdram_wire_dqm(DRAM_DQM),      //  .dqm
        .sdram_wire_ras_n(DRAM_RAS_N),  //  .ras_n
        .sdram_wire_we_n(DRAM_WE_N),    //  .we_n
        .sdram_clk_clk(DRAM_CLK)        //  clock out to SDRAM from other PLL port
    );

    sync switch_sync[17:0] (CLOCK_50, SW, SW_Sync);
    sync button_sync[3:0] (CLOCK_50, KEY, KEY_Sync);

endmodule
