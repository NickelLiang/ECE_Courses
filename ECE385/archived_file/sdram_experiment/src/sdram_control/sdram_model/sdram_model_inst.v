	sdram_model u0 (
		.clk_clk                               (<connected-to-clk_clk>),                               //                     clk.clk
		.reset_reset_n                         (<connected-to-reset_reset_n>),                         //                   reset.reset_n
		.sdram_controller_master_address       (<connected-to-sdram_controller_master_address>),       // sdram_controller_master.address
		.sdram_controller_master_byteenable_n  (<connected-to-sdram_controller_master_byteenable_n>),  //                        .byteenable_n
		.sdram_controller_master_chipselect    (<connected-to-sdram_controller_master_chipselect>),    //                        .chipselect
		.sdram_controller_master_writedata     (<connected-to-sdram_controller_master_writedata>),     //                        .writedata
		.sdram_controller_master_read_n        (<connected-to-sdram_controller_master_read_n>),        //                        .read_n
		.sdram_controller_master_write_n       (<connected-to-sdram_controller_master_write_n>),       //                        .write_n
		.sdram_controller_master_readdata      (<connected-to-sdram_controller_master_readdata>),      //                        .readdata
		.sdram_controller_master_readdatavalid (<connected-to-sdram_controller_master_readdatavalid>), //                        .readdatavalid
		.sdram_controller_master_waitrequest   (<connected-to-sdram_controller_master_waitrequest>),   //                        .waitrequest
		.sdram_wire_addr                       (<connected-to-sdram_wire_addr>),                       //              sdram_wire.addr
		.sdram_wire_ba                         (<connected-to-sdram_wire_ba>),                         //                        .ba
		.sdram_wire_cas_n                      (<connected-to-sdram_wire_cas_n>),                      //                        .cas_n
		.sdram_wire_cke                        (<connected-to-sdram_wire_cke>),                        //                        .cke
		.sdram_wire_cs_n                       (<connected-to-sdram_wire_cs_n>),                       //                        .cs_n
		.sdram_wire_dq                         (<connected-to-sdram_wire_dq>),                         //                        .dq
		.sdram_wire_dqm                        (<connected-to-sdram_wire_dqm>),                        //                        .dqm
		.sdram_wire_ras_n                      (<connected-to-sdram_wire_ras_n>),                      //                        .ras_n
		.sdram_wire_we_n                       (<connected-to-sdram_wire_we_n>)                        //                        .we_n
	);

