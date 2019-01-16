module datapath (
    input   logic           Clk, Reset,
    input   logic           GatePC, GateMDR, GateALU, GateMARMUX,
    input   logic           LD_MAR, LD_MDR, LD_IR, LD_BEN,
                            LD_CC, LD_REG, LD_PC, LD_LED,
    input   logic           MIO_EN,
    input   logic [1:0]     PCMUX, ADDR2MUX, ALUK,
    input   logic           DRMUX, SR1MUX, SR2MUX, ADDR1MUX,
    input   logic [15:0]    MDR_In,
    output  logic           BEN,
    output  logic [15:0]    PC, IR, MAR, MDR,
    output  logic [11:0]    LED
    );

    logic N, Z, P;
    logic [15:0] DATA_BUS, ALU, SR1_OUT, SR2_OUT, DATA_ADDER;

    // The ULTIMATE BUS
    data_bus dbus(.*, .MARMUX(DATA_ADDER));

    // PC
    program_counter pc_reg(.*, .PC_OUT(PC));

    // IR
    register_nbit inst_reg(.Clk, .Reset, .Load(LD_IR), .D_In(DATA_BUS), .D_Out(IR));

    // MAR
    register_nbit ma_reg(.Clk, .Reset, .Load(LD_MAR), .D_In(DATA_BUS), .D_Out(MAR));

    // MDR
    logic [15:0] MDR_INPUT;
    register_nbit md_reg(.Clk, .Reset, .Load(LD_MDR), .D_In(MDR_INPUT), .D_Out(MDR));
    assign MDR_INPUT = MIO_EN ? MDR_In : DATA_BUS;

    // LED
    register_nbit #(12) led_reg(.Clk, .Reset, .Load(LD_LED), .D_In(IR[11:0]), .D_Out(LED));

    // ADDER
    adder adder(.*, .BaseR(SR1_OUT));

    // Register File
    reg_file rf(.*);

    // ALU
    alu alu(.*);

    // Compare
    cc cc(.*);
    ben ben(.*);

endmodule
