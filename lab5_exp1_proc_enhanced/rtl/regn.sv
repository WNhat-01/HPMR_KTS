// ============================================================================
// Module: regn
// Description: Parameterized N-bit register with parallel load enable (Rin)
// ============================================================================
module regn #(
    parameter int N = 9
) (
    input  logic [N-1:0] R,
    input  logic         Rin,
    input  logic         Clock,
    output logic [N-1:0] Q = '0
);

    always_ff @(posedge Clock) begin
        if (Rin) begin
            Q <= R;
        end
    end

endmodule
