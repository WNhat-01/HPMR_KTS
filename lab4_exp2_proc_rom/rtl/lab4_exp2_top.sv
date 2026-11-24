// ============================================================================
// Module: lab4_exp2_top
// Description: Lab 4 Experiment 2 - Simple Processor connected to 32x9 ROM
//              and 5-bit Address Counter (Figure 3)
// ============================================================================
module lab4_exp2_top #(
    parameter INIT_FILE_MEM = "../mem/my_ROM.mem"
) (
    input  logic       MClock,
    input  logic       PClock,
    input  logic       Resetn,
    input  logic       Run,
    output logic [8:0] Bus,
    output logic       Done
);

    logic [4:0] rom_addr;
    logic [8:0] rom_data;

    counter5 u_counter (
        .Clock (MClock),
        .Resetn(Resetn),
        .Q     (rom_addr)
    );

    my_rom #(
        .WIDTH        (9),
        .DEPTH        (32),
        .ADDR_BITS    (5),
        .INIT_FILE_MEM(INIT_FILE_MEM)
    ) u_rom (
        .CLK    (MClock),
        .ADDRESS(rom_addr),
        .DATAOUT(rom_data)
    );

    proc u_proc (
        .DIN     (rom_data),
        .Resetn  (Resetn),
        .Clock   (PClock),
        .Run     (Run),
        .Done    (Done),
        .BusWires(Bus)
    );

endmodule
