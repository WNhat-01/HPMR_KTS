// ============================================================================
// Module: pc_counter
// Description: 9-bit Program Counter (Register R7) with active-low async reset,
//              parallel load (L = R7in), and increment enable (E = incr_pc)
// ============================================================================
module pc_counter #(
    parameter int N = 9
) (
    input  logic [N-1:0] R,
    input  logic         L,
    input  logic         E,
    input  logic         Clock,
    input  logic         Resetn,
    output logic [N-1:0] Q
);

    always_ff @(posedge Clock, negedge Resetn) begin
        if (!Resetn) begin
            Q <= '0;
        end else if (L) begin
            Q <= R;
        end else if (E) begin
            Q <= Q + {{(N-1){1'b0}}, 1'b1};
        end
    end

endmodule
