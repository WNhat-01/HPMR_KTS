// ============================================================================
// Module: addsub
// Description: Parameterized N-bit Adder/Subtractor
// ============================================================================
module addsub #(
    parameter int N = 9
) (
    input  logic [N-1:0] A,
    input  logic [N-1:0] B,
    input  logic         AddSub,
    output logic [N-1:0] Result
);

    always_comb begin
        if (!AddSub) begin
            Result = A + B;
        end else begin
            Result = A - B;
        end
    end

endmodule
