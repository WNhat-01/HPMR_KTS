// ============================================================================
// Module: ram128x9
// Description: 128 x 9-bit Single-Port Synchronous RAM (RAM: 1-PORT)
//              - Registered inputs: address[6:0], data[8:0], wren
//              - Unregistered output: q[8:0]
//              - Infers Cyclone V M10K embedded RAM (altsyncram) in Quartus
//                initialized from mem/program_fpga.mif
// ============================================================================
module ram128x9 #(
    parameter INIT_FILE_MEM = "../mem/program_sim.mem"
) (
    input  logic [6:0] address,
    input  logic       clock,
    input  logic [8:0] data,
    input  logic       wren,
    output logic [8:0] q
);

    (* ramstyle = "M10K", ram_init_file = "mem/program_fpga.mif" *)
    logic [8:0] mem [0:127];

    logic [6:0] addr_reg = 7'd0;

    // synthesis translate_off
    initial begin
        for (int i = 0; i < 128; i++) begin
            mem[i] = 9'd0;
        end
        $readmemb(INIT_FILE_MEM, mem);
    end
    // synthesis translate_on

    always @(posedge clock) begin
        addr_reg <= address;
        if (wren) begin
            mem[address] <= data;
        end
    end

    assign q = mem[addr_reg];

endmodule
