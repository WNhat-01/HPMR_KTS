// ============================================================================
// Module: run_sync
// Description: Two-stage flip-flop synchronizer for asynchronous Run input (SW9)
//              as required by Lab 5 specification (page 5)
// ============================================================================
module run_sync (
    input  logic Clock,
    input  logic Resetn,
    input  logic async_in,
    output logic sync_out
);

    (* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" *)
    logic ff1, ff2;

    always_ff @(posedge Clock, negedge Resetn) begin
        if (!Resetn) begin
            ff1 <= 1'b0;
            ff2 <= 1'b0;
        end else begin
            ff1 <= async_in;
            ff2 <= ff1;
        end
    end

    assign sync_out = ff2;

endmodule
