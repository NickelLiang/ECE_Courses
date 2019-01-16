module camera_capture (
    input  logic [11:0] iDATA,
    input  logic        iFVAL,
    input  logic        iLVAL,
    input  logic        iSTART,
    input  logic        iEND,
    input  logic        iCLK,
    input  logic        iRST,
    output logic [11:0] oDATA,
    output logic [15:0] oX_Cont,
    output logic [15:0] oY_Cont,
    output logic [31:0] oFrame_Cont,
    output logic        oDVAL
    );

    parameter COLUMN_WIDTH = 1280;

    reg             Pre_FVAL;
    reg             mCCD_FVAL;
    reg             mCCD_LVAL;
    reg     [11:0]  mCCD_DATA;
    reg     [15:0]  X_Cont;
    reg     [15:0]  Y_Cont;
    reg     [31:0]  Frame_Cont;
    reg             mSTART;

    assign  oX_Cont         = X_Cont;
    assign  oY_Cont         = Y_Cont;
    assign  oFrame_Cont     = Frame_Cont;
    assign  oDATA           = mCCD_DATA;
    assign  oDVAL           = mCCD_FVAL & mCCD_LVAL;

    // Start Capture and Stop Capture Control
    always @ (posedge iCLK or negedge iRST) begin
        if (!iRST)
            mSTART  <= 1'b0;
        else begin
            if (iSTART)
                mSTART  <= 1'b1;
            if (iEND)
                mSTART  <= 1'b0;
        end
    end

    // X and Y Coordinate Generation
    always @ (posedge iCLK or negedge iRST) begin
        if (!iRST) begin
            Pre_FVAL    <= 1'b0;
            mCCD_FVAL   <= 1'b0;
            mCCD_LVAL   <= 1'b0;
            X_Cont      <= 16'b0;
            Y_Cont      <= 16'b0;
        end else begin
            Pre_FVAL    <= iFVAL;
            if (({Pre_FVAL, iFVAL} == 2'b01) && mSTART)
                mCCD_FVAL   <= 1'b1;
            else if ({Pre_FVAL, iFVAL} == 2'b10)
                mCCD_FVAL   <= 1'b0;
                mCCD_LVAL   <= iLVAL;
            if (mCCD_FVAL) begin
                if (mCCD_LVAL) begin
                    if (X_Cont < (COLUMN_WIDTH - 16'd1))
                        X_Cont  <= X_Cont + 16'd1;
                    else begin
                        X_Cont  <= 16'b0;
                        Y_Cont  <= Y_Cont + 16'b1;
                    end
                end
            end else begin
                X_Cont      <= 16'b0;
                Y_Cont      <= 16'b0;
            end
        end
    end

    // Frame Count Calculation
    always @ (posedge iCLK or negedge iRST) begin
        if (!iRST)
            Frame_Cont  <= 32'b0;
        else begin
            if(({Pre_FVAL,iFVAL} == 2'b01) && mSTART)
            Frame_Cont  <= Frame_Cont + 32'b1;
        end
    end

    // CCD Data Selection
    always @ (posedge iCLK or negedge iRST) begin
        if (!iRST)
            mCCD_DATA   <= 12'b0;
        else if (iLVAL)
            mCCD_DATA   <= iDATA;
        else
            mCCD_DATA   <= 12'b0;
    end
endmodule // camera_capture
