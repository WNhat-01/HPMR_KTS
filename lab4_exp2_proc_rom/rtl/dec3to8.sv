// ============================================================================
// Module: dec3to8
// Description: 3-to-8 active-high decoder (Y[0] = R0 ... Y[7] = R7)
// ============================================================================
module dec3to8 (
    input  logic [2:0] W,
    input  logic       En,
    output logic [7:0] Y
);

    always_comb begin
        if (En) begin
            case (W)
                3'b000:  Y = 8'b0000_0001;
                3'b001:  Y = 8'b0000_0010;
                3'b010:  Y = 8'b0000_0100;
                3'b011:  Y = 8'b0000_1000;
                3'b100:  Y = 8'b0001_0000;
                3'b101:  Y = 8'b0010_0000;
                3'b110:  Y = 8'b0100_0000;
                3'b111:  Y = 8'b1000_0000;
                default: Y = 8'b0000_0000;
            endcase
        end else begin
            Y = 8'b0000_0000;
        end
    end

endmodule
