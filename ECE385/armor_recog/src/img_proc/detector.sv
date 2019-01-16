module ratio_check (
    input  logic [9:0]  iWIDTH, iHEIGHT,
    output logic        oVALID
);
    logic [9:0] MIN_MAP, MAX_MAP;
    assign MIN_MAP = { iHEIGHT[8:0], 1'b0 } + { 1'b0, iHEIGHT[9:1] }; // MIN_MAP = 2.5 * height
    assign MAX_MAP = { iHEIGHT[8:0], 1'b0 } + iHEIGHT; // MAX_MAP = 3.25 * height

    assign oVALID = (iWIDTH >= MIN_MAP) & (iWIDTH <= MAX_MAP);
endmodule

module detector (
    input  logic        iCLK,
    input  logic        iRESET,
    input  logic [7:0]  iDATA,
    output logic [16:0] oRDADDR,
    output logic [9:0]  oX, oY, oWIDTH, oHEIGHT
);
    parameter WIDTH     = 10'd320;
    parameter HEIGHT    = 10'd240;
    parameter MIN_VLEN  = 10'd15; // minimum vertical strike length to be considered as valid strike
    parameter MAX_DIFF  = 10'd20;

    /* internel counter and next state variable */
    enum logic [1:0] {PRESEARCH, FOUND1, SEARCH, FOUND2} state, state_next;
    logic [9:0] mX, mY, mWIDTH, mHEIGHT;                // output next state
    logic [9:0] Xtmp, Wtmp, Htmp, mXtmp, mWtmp, mHtmp;  // temporary location capture
    logic [9:0] Xtmp1, Htmp1, mXtmp1, mHtmp1;           // temporary value buffer for 2nd found strike
    logic [9:0] Xcnt, Ycnt, mXcnt, mYcnt;               // position (next) state
    logic o; // generic overflow bit

    assign oRDADDR = Ycnt * WIDTH + Xcnt;

    /* ratio check module */
    logic ratio_valid;
    ratio_check rc (.iWIDTH(Wtmp), .iHEIGHT(Htmp), .oVALID(ratio_valid));

    always_comb begin
        /* default transition */
        mX      = oX;
        mY      = oY;
        mWIDTH  = oWIDTH;
        mHEIGHT = oHEIGHT;
        mXtmp   = Xtmp;
        mWtmp   = Wtmp;
        mHtmp   = Htmp;
        mXtmp1  = Xtmp1;
        mHtmp1  = Htmp1;
        state_next = state;
        mXcnt   = Xcnt + 10'b1;
        mYcnt   = Ycnt;
        /* fixed transition */
        if (Xcnt == WIDTH - 10'b1) begin
            mXcnt = 10'b0;
            mYcnt = Ycnt + 10'b1;
            if (Ycnt == HEIGHT - 10'b1) begin
                mYcnt   = 10'b0;
                /* reset bbox if nothing found */
                mX      = 10'b0;
                mY      = 10'b0;
                mWIDTH  = 10'b0;
                mHEIGHT = 10'b0;
            end
        end
        /* floating transition */
        case (state)
            PRESEARCH:
                if (iDATA > MIN_VLEN) begin
                    state_next  = FOUND1;
                    mWtmp       = 10'b0;
                    mHtmp       = iDATA;
                    mXtmp       = Xcnt;
                end
            FOUND1: begin
                mHtmp   = (iDATA > Htmp) ?  iDATA : Htmp;
                mXtmp   = (iDATA > Htmp) ?  Xcnt  : Xtmp;
                mWtmp   = (iDATA > Htmp) ?  10'b0 : Wtmp + 1'b1;
                if (iDATA < MIN_VLEN)
                    state_next  = SEARCH;
            end
            SEARCH: begin
                mWtmp   = Wtmp + 10'b1;
                if (iDATA > MIN_VLEN) begin
                    state_next  = FOUND2;
                    mHtmp1      = iDATA;
                    mXtmp1      = Xcnt;
                end
            end
            FOUND2: begin
                mWtmp   = Wtmp + 10'b1;
                mHtmp1  = (iDATA > Htmp1) ? iDATA : Htmp1;
                mXtmp1  = (iDATA > Htmp1) ? Xcnt  : Xtmp1;
                if (iDATA < MIN_VLEN) begin
                    if (((Htmp > Htmp1 && Htmp - Htmp1 <= MAX_DIFF) ||
                         (Htmp <= Htmp1 && Htmp1 - Htmp <= MAX_DIFF)) && ratio_valid) begin
                        mX              = Xtmp;
                        mY              = Ycnt;
                        mWIDTH          = Wtmp;
                        { mHEIGHT, o }  = Htmp + Htmp1; // mHEIGHT = (Htmp + Htmp1) / 2
                        mXcnt           = 10'b0;
                        mYcnt           = 10'b0;
                        state_next      = PRESEARCH;
                    end else begin
                        mXtmp           = Xtmp1;
                        mHtmp           = Htmp1;
                        mWtmp           = 10'b0;
                        state_next      = SEARCH;
                    end
                end
            end
        endcase
        /* highest priority state transition */
        if (Xcnt == WIDTH - 10'b1)
            state_next = PRESEARCH;
    end

    always_ff @ (posedge iCLK or posedge iRESET) begin
        if (iRESET) begin
            oX      <= 10'b0;
            oY      <= 10'b0;
            oWIDTH  <= 10'b0;
            oHEIGHT <= 10'b0;
            Xcnt    <= 10'b0;
            Ycnt    <= 10'b0;
            Xtmp    <= 10'b0;
            Wtmp    <= 10'b0;
            Htmp    <= 10'b0;
            Xtmp1   <= 10'b0;
            Htmp1   <= 10'b0;
            state   <= PRESEARCH;
        end else begin
            oX      <= mX;
            oY      <= mY;
            oWIDTH  <= mWIDTH;
            oHEIGHT <= mHEIGHT;
            Xcnt    <= mXcnt;
            Ycnt    <= mYcnt;
            Xtmp    <= mXtmp;
            Wtmp    <= mWtmp;
            Htmp    <= mHtmp;
            Xtmp1   <= mXtmp1;
            Htmp1   <= mHtmp1;
            state   <= state_next;
        end
    end
endmodule

module detector_bridge (
    input  logic        iCLK,
    input  logic        iRESET,
    input  logic [7:0]  iDATA,
    output logic [16:0] oRDADDR,
    output logic [9:0]  oLEFT, oRIGHT, oTOP, oBOTTOM
);
    logic [9:0] oX, oY, oWIDTH, oHEIGHT;
    detector dt(.*);

    /* double all values to match interpolated coordinate */
    assign oLEFT    = { oX[8:0], 1'b0 };
    assign oRIGHT   = oLEFT + { oWIDTH[8:0], 1'b0 };
    assign oTOP     = { oY[8:0], 1'b0 };
    assign oBOTTOM  = oTOP + { oHEIGHT[8:0], 1'b0 };
endmodule
