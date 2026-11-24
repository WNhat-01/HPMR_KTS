// ============================================================================
// Module: my_rom
// Description: 32 x 9-bit synchronous ROM with 5-bit registered address input
//              and combinational 9-bit data output (Pre-Lab 4 Ex 3 & Lab 4 Fig 4)
// ============================================================================
module my_rom #(
    parameter int unsigned WIDTH         = 9,
    parameter int unsigned DEPTH         = 32,
    parameter int unsigned ADDR_BITS     = 5,
    parameter              INIT_FILE_MEM = "../mem/my_ROM.mem"
) (
    input  logic                 CLK,
    input  logic [ADDR_BITS-1:0] ADDRESS,
    output logic [WIDTH-1:0]     DATAOUT
);

    (* ram_init_file = "mem/my_ROM.mif" *)
    logic [WIDTH-1:0] rom [0:DEPTH-1];

    logic [ADDR_BITS-1:0] addr_reg = '0;

    // synthesis translate_off
    initial begin
        $readmemb(INIT_FILE_MEM, rom);
    end
    // synthesis translate_on

    always_ff @(posedge CLK) begin
        addr_reg <= ADDRESS;
    end

    assign DATAOUT = rom[addr_reg];

endmodule
