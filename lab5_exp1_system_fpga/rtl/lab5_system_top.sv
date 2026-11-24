// ============================================================================
// Module: lab5_system_top
// Description: Lab 5 Full System Top-Level for Terasic DE10-Standard (50 MHz)
//              Implements Figure 2:
//                - Enhanced Processor (proc_enhanced)
//                - Address Decoder:
//                    A8A7 == 2'b00 -> RAM write enable: ~(A8 | A7) & W
//                    A8A7 == 2'b01 -> LEDs reg enable:  (~A8 & A7) & W
//                - 128 x 9-bit Synchronous RAM: 1-PORT (unregistered q)
//                - 9-bit LEDs Output Register -> LEDR[8:0]
//                - 2-FF Synchronizer on asynchronous SW[9] (Run)
//
// DE10-Standard Pin Mapping:
//   CLOCK_50  : 50 MHz board clock
//   KEY[0]    : Resetn (active-low push button)
//   SW[9]     : Run    (slide switch, synchronized)
//   LEDR[8:0] : 9-bit output register display
// ============================================================================
module lab5_system_top #(
    parameter INIT_FILE_MEM = "../mem/program_sim.mem"
) (
    input  logic       CLOCK_50,
    input  logic [0:0] KEY,
    input  logic [9:9] SW,
    output logic [8:0] LEDR
);

    logic       Resetn;
    logic       Run_sync;
    logic [8:0] ADDR;
    logic [8:0] DOUT;
    logic [8:0] DIN;
    logic       W;
    logic       Done;

    // Address decoding signals (Lab 5 Figure 2)
    logic       sel_mem;
    logic       sel_leds;
    logic       mem_wr_en;
    logic       led_en;

    assign Resetn = KEY[0];

    // 2-FF Synchronizer for asynchronous Run input (SW[9])
    run_sync u_run_sync (
        .Clock   (CLOCK_50),
        .Resetn  (Resetn),
        .async_in(SW[9]),
        .sync_out(Run_sync)
    );

    // Enhanced 9-bit Processor
    proc_enhanced u_proc (
        .DIN   (DIN),
        .Resetn(Resetn),
        .Clock (CLOCK_50),
        .Run   (Run_sync),
        .ADDR  (ADDR),
        .DOUT  (DOUT),
        .W     (W),
        .Done  (Done)
    );

    // Address Decoder (matching Figure 2 gates):
    //   A8A7 = 00 -> ~(A8 | A7) = ~ADDR[8] & ~ADDR[7]  -> RAM
    //   A8A7 = 01 -> ~(A8 | ~A7) = ~ADDR[8] & ADDR[7]  -> LEDs register
    assign sel_mem   = ~(ADDR[8] | ADDR[7]);
    assign sel_leds  = ~(ADDR[8] | ~ADDR[7]);
    assign mem_wr_en = sel_mem  & W;
    assign led_en    = sel_leds & W;

    // 128 x 9-bit RAM: 1-PORT (7 lower address bits A6..A0)
    ram128x9 #(
        .INIT_FILE_MEM(INIT_FILE_MEM)
    ) u_ram (
        .address(ADDR[6:0]),
        .clock  (CLOCK_50),
        .data   (DOUT),
        .wren   (mem_wr_en),
        .q      (DIN)
    );

    // 9-bit LEDs Output Register (connected to LEDR[8:0])
    regn #(.N(9)) u_leds_reg (
        .R    (DOUT),
        .Rin  (led_en),
        .Clock(CLOCK_50),
        .Q    (LEDR)
    );

endmodule
