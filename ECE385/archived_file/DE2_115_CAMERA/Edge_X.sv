module Edge_X (
    input  logic        iCLK,
    input  logic        iReset,
    input  logic        iDVAL,
    input  logic [9:0]  iRed,
    input  logic [9:0]  iGreen,
    input  logic [9:0]  iBlue,
    output logic        oDVAL,
    output logic [7:0]  oData
);

    logic [7:0] gray;
    RGB10_TO_GRAY8(.*, .oGray(gray));
    
    logic [17:0] raw_result, normalized;
    logic O;
    MAC_3 ( .aclr3(iReset),
            .clock0(iCLK),
            .dataa_0(gray),
            .datab_0(8'd1),
            .datab_1(8'd0),
            .datab_2(-8'd1),
            .ena0(iDVAL),
            .result(raw_result));
            
    always_comb begin
        {O, normalized} = raw_result + 17'd256;
        oData           = normalized[8:1];
        //oData = 8'd255;
    end
    
    always_ff @ (posedge iCLK) begin
        oDVAL <= oDVAL;
        if (iReset)
            oDVAL <= 0;
        else
            oDVAL <= iDVAL;
    end
    

endmodule

module RGB10_TO_GRAY8(
    input  logic [9:0]  iRed,
    input  logic [9:0]  iGreen,
    input  logic [9:0]  iBlue,
    output logic [7:0]  oGray
);

    logic [10:0] rbsum;
    
    always_comb begin
        rbsum    = iRed + iBlue;
        oGray    = rbsum[10:3];
    end

endmodule
