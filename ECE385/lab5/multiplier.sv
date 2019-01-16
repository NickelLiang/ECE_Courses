module multiplier (
    input   logic [7:0] S,
    input   logic       Clk, Reset, Run, ClearA_LoadB,
    output  logic [6:0] AhexU, AhexL, BhexU, BhexL,
    output  logic [7:0] Aval, Bval,
    output  logic       X
    );
    logic [7:0] A, B, S_S;

    logic Shift, F, ClrA;
    logic ClrA_LdB_SH, Reset_SH, Run_SH;

    arithmetic_unit ALU(.S(S_S), .Shift, .F,
        .ClrA_LdB(ClrA_LdB_SH), .ClrA, .Clk, .A, .B, .X);
    control CTL(.Clk, .Reset(Reset_SH), .Run(Run_SH), .Shift, .F, .ClrA);

    hex_driver  HexAL(.In0(A[3:0]), .Out0(AhexL));
    hex_driver  HexAU(.In0(A[7:4]), .Out0(AhexU));
    hex_driver  HexBL(.In0(B[3:0]), .Out0(BhexL));
    hex_driver  HexBU(.In0(B[7:4]), .Out0(BhexU));

    sync switch_sync[7:0] (Clk, S, S_S);
    sync button_sync[2:0] (Clk, {~ClearA_LoadB, ~Reset, ~Run},
                                {ClrA_LdB_SH, Reset_SH, Run_SH});

    always_comb begin
        Aval = A;
        Bval = B;
    end
endmodule
