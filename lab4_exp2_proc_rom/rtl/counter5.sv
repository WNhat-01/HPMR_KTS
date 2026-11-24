// ============================================================================
// Module: counter5
// Description: 5-bit up-counter for Lab 4 Experiment 2 ROM addressing (0..31)
//              Active-low asynchronous reset (Resetn)
// ============================================================================
module counter5 (
    input  logic       Clock,
    input  logic       Resetn,
    output logic [4:0] Q
);

    always_ff @(posedge Clock, negedge Resetn) begin
        if (!Resetn) begin
            Q <= 5'd0;
        end else begin
            Q <= Q + 5'd1;
        end
    end

endmodule
