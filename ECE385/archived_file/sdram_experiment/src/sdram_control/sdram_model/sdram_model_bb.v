
module sdram_model (
	clk_clk,
	reset_reset_n,
	sdram_controller_master_address,
	sdram_controller_master_byteenable_n,
	sdram_controller_master_chipselect,
	sdram_controller_master_writedata,
	sdram_controller_master_read_n,
	sdram_controller_master_write_n,
	sdram_controller_master_readdata,
	sdram_controller_master_readdatavalid,
	sdram_controller_master_waitrequest,
	sdram_wire_addr,
	sdram_wire_ba,
	sdram_wire_cas_n,
	sdram_wire_cke,
	sdram_wire_cs_n,
	sdram_wire_dq,
	sdram_wire_dqm,
	sdram_wire_ras_n,
	sdram_wire_we_n);	

	input		clk_clk;
	input		reset_reset_n;
	input	[24:0]	sdram_controller_master_address;
	input	[3:0]	sdram_controller_master_byteenable_n;
	input		sdram_controller_master_chipselect;
	input	[31:0]	sdram_controller_master_writedata;
	input		sdram_controller_master_read_n;
	input		sdram_controller_master_write_n;
	output	[31:0]	sdram_controller_master_readdata;
	output		sdram_controller_master_readdatavalid;
	output		sdram_controller_master_waitrequest;
	output	[12:0]	sdram_wire_addr;
	output	[1:0]	sdram_wire_ba;
	output		sdram_wire_cas_n;
	output		sdram_wire_cke;
	output		sdram_wire_cs_n;
	inout	[31:0]	sdram_wire_dq;
	output	[3:0]	sdram_wire_dqm;
	output		sdram_wire_ras_n;
	output		sdram_wire_we_n;
endmodule
