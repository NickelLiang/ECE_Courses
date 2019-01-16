// 8-bit generic shift right register
module register_8bit (
    input  logic       Clk, Reset, Shift_In, Load, Shift_En,
    input  logic [7:0] D,
    output logic       Shift_Out,
    output logic [7:0] Data_Out
    );
    logic [7:0] Data_Next;

    always_ff @ (posedge Clk) begin
        Data_Out <= Data_Next;
    end

    always_comb begin
        Data_Next = Data_Out;
        if (Reset)
            Data_Next = 8'h00;
        else begin
            case ({Load, Shift_En})
                2'b00: Data_Next = Data_Out;
                2'b01: Data_Next = { Shift_In, Data_Out[7:1] };
                2'b10: Data_Next = D;
                2'b11: Data_Next = { Shift_In, D[7:1] };
            endcase
        end
        case (Load & Shift_En)
            1'b0: Shift_Out = Data_Out[0];
            1'b1: Shift_Out = D[0];
        endcase
    end
endmodule

// 9-bit arithmetic shift right register
module register_9bit (
    input  logic       Clk, Reset, Load, Shift_En,
    input  logic [8:0] D,
    output logic       Shift_Out,
    output logic [8:0] Data_Out
    );

    logic [8:0] Data_Next;

    always_ff @ (posedge Clk) begin
        Data_Out <= Data_Next;
    end

    always_comb begin
        Data_Next = Data_Out;
        if (Reset)
            Data_Next = 9'h00;
        else begin
            case ({Load, Shift_En})
                2'b00: Data_Next = Data_Out;
                2'b01: Data_Next = { Data_Out[8], Data_Out[8:1] };
                2'b10: Data_Next = D;
                2'b11: Data_Next = { D[8], D[8:1] };
            endcase
        end
        case (Load & Shift_En)
            1'b0: Shift_Out = Data_Out[0];
            1'b1: Shift_Out = D[0];
        endcase
    end
endmodule
