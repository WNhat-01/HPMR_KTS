// ============================================================================
// Module: proc_enhanced
// Description: Lab 5 Enhanced 9-bit Processor (Figure 1)
//              Designed for synchronous external memory with registered inputs
//              (address, data, wr_en) and unregistered output (q).
//
// Instructions (III_XXX_YYY):
//   000 (mv)  : Rx <- Ry
//   001 (mvi) : Rx <- Mem[PC++]
//   010 (add) : Rx <- Rx + Ry
//   011 (sub) : Rx <- Rx - Ry
//   100 (ld)  : Rx <- Mem[Ry]
//   101 (st)  : Mem/Peripheral[Ry] <- Rx
//   110 (mvnz): if (G != 0) Rx <- Ry
// ============================================================================
module proc_enhanced (
    input  logic [8:0] DIN,
    input  logic       Resetn,
    input  logic       Clock,
    input  logic       Run,
    output logic [8:0] ADDR,
    output logic [8:0] DOUT,
    output logic       W,
    output logic       Done
);

    // 6-state Control FSM (accounts for 1-cycle registered-input memory latency)
    typedef enum logic [2:0] {
        T0 = 3'b000, // Fetch 1: ADDR <- R7 (PC), R7 <- R7 + 1 (when Run=1)
        T1 = 3'b001, // Fetch 2: Wait for synchronous memory address register
        T2 = 3'b010, // Fetch 3: IR <- DIN
        T3 = 3'b011, // Execute 1
        T4 = 3'b100, // Execute 2
        T5 = 3'b101  // Execute 3
    } state_t;

    // Instruction opcodes
    localparam logic [2:0] OP_MV   = 3'b000;
    localparam logic [2:0] OP_MVI  = 3'b001;
    localparam logic [2:0] OP_ADD  = 3'b010;
    localparam logic [2:0] OP_SUB  = 3'b011;
    localparam logic [2:0] OP_LD   = 3'b100;
    localparam logic [2:0] OP_ST   = 3'b101;
    localparam logic [2:0] OP_MVNZ = 3'b110;

    state_t Tstep_Q, Tstep_D;

    // Instruction register & decoded fields
    logic [8:0] IR;
    logic [2:0] I;
    logic [7:0] Xreg, Yreg;

    // Control signals
    logic       IRin;
    logic [7:0] Rin, Rout;
    logic       incr_pc;
    logic       Ain, Gin, Gout, DINout, AddSub;
    logic       ADDRin, DOUTin, W_D;

    // Datapath signals
    logic [8:0] R0, R1, R2, R3, R4, R5, R6, R7;
    logic [8:0] A, G, Sum, BusWires;
    logic       G_not_zero;

    assign I          = IR[8:6];
    assign G_not_zero = |G;

    dec3to8 decX (.W(IR[5:3]), .En(1'b1), .Y(Xreg));
    dec3to8 decY (.W(IR[2:0]), .En(1'b1), .Y(Yreg));

    // ------------------------------------------------------------------------
    // Control FSM: Next-state logic
    // ------------------------------------------------------------------------
    always_comb begin
        case (Tstep_Q)
            T0:      Tstep_D = (!Run) ? T0 : T1;
            T1:      Tstep_D = T2;
            T2:      Tstep_D = T3;
            T3:      Tstep_D = (Done) ? T0 : T4;
            T4:      Tstep_D = T5;
            T5:      Tstep_D = T0;
            default: Tstep_D = T0;
        endcase
    end

    // ------------------------------------------------------------------------
    // Control FSM: Output logic
    // ------------------------------------------------------------------------
    always_comb begin
        IRin    = 1'b0;
        Rin     = 8'b0000_0000;
        Rout    = 8'b0000_0000;
        incr_pc = 1'b0;
        Ain     = 1'b0;
        Gin     = 1'b0;
        Gout    = 1'b0;
        DINout  = 1'b0;
        AddSub  = 1'b0;
        ADDRin  = 1'b0;
        DOUTin  = 1'b0;
        W_D     = 1'b0;
        Done    = 1'b0;

        case (Tstep_Q)
            T0: begin
                // Start fetching instruction only when Run is asserted
                if (Run) begin
                    Rout    = 8'b1000_0000; // R7out (PC)
                    ADDRin  = 1'b1;
                    incr_pc = 1'b1;
                end
            end

            T1: begin
                // Wait 1 cycle for external synchronous memory to register ADDR
            end

            T2: begin
                // Instruction word is now valid on DIN; latch into IR
                IRin = 1'b1;
            end

            T3: begin
                case (I)
                    OP_MV: begin
                        Rout = Yreg;
                        Rin  = Xreg;
                        Done = 1'b1;
                    end
                    OP_MVI: begin
                        // Put PC (pointing to immediate word) onto ADDR, advance PC
                        Rout    = 8'b1000_0000; // R7out
                        ADDRin  = 1'b1;
                        incr_pc = 1'b1;
                    end
                    OP_ADD, OP_SUB: begin
                        Rout = Xreg;
                        Ain  = 1'b1;
                    end
                    OP_LD: begin
                        Rout   = Yreg;
                        ADDRin = 1'b1;
                    end
                    OP_ST: begin
                        Rout   = Yreg;
                        ADDRin = 1'b1;
                    end
                    OP_MVNZ: begin
                        if (G_not_zero) begin
                            Rout = Yreg;
                            Rin  = Xreg;
                        end
                        Done = 1'b1;
                    end
                    default: begin
                        Done = 1'b1;
                    end
                endcase
            end

            T4: begin
                case (I)
                    OP_MVI: begin
                        // Wait 1 cycle for synchronous memory to register immediate ADDR
                    end
                    OP_ADD: begin
                        Rout   = Yreg;
                        AddSub = 1'b0;
                        Gin    = 1'b1;
                    end
                    OP_SUB: begin
                        Rout   = Yreg;
                        AddSub = 1'b1;
                        Gin    = 1'b1;
                    end
                    OP_LD: begin
                        // Wait 1 cycle for synchronous memory to register load ADDR
                    end
                    OP_ST: begin
                        // Load DOUT with Rx and assert W_D so W=1 during T5
                        Rout   = Xreg;
                        DOUTin = 1'b1;
                        W_D    = 1'b1;
                    end
                    default: ;
                endcase
            end

            T5: begin
                case (I)
                    OP_MVI: begin
                        DINout = 1'b1;
                        Rin    = Xreg;
                        Done   = 1'b1;
                    end
                    OP_ADD, OP_SUB: begin
                        Gout = 1'b1;
                        Rin  = Xreg;
                        Done = 1'b1;
                    end
                    OP_LD: begin
                        DINout = 1'b1;
                        Rin    = Xreg;
                        Done   = 1'b1;
                    end
                    OP_ST: begin
                        // W is HIGH during T5; external RAM/LED latches on posedge ending T5
                        Done = 1'b1;
                    end
                    default: begin
                        Done = 1'b1;
                    end
                endcase
            end

            default: ;
        endcase
    end

    // ------------------------------------------------------------------------
    // Control FSM & Write-enable Flip-Flops
    // ------------------------------------------------------------------------
    always_ff @(posedge Clock, negedge Resetn) begin
        if (!Resetn) begin
            Tstep_Q <= T0;
            W       <= 1'b0;
        end else begin
            Tstep_Q <= Tstep_D;
            W       <= W_D;
        end
    end

    // ------------------------------------------------------------------------
    // Datapath: Registers, PC (R7), ALU, ADDR, DOUT
    // ------------------------------------------------------------------------
    regn #(.N(9)) reg_0    (.R(BusWires), .Rin(Rin[0]), .Clock(Clock), .Q(R0));
    regn #(.N(9)) reg_1    (.R(BusWires), .Rin(Rin[1]), .Clock(Clock), .Q(R1));
    regn #(.N(9)) reg_2    (.R(BusWires), .Rin(Rin[2]), .Clock(Clock), .Q(R2));
    regn #(.N(9)) reg_3    (.R(BusWires), .Rin(Rin[3]), .Clock(Clock), .Q(R3));
    regn #(.N(9)) reg_4    (.R(BusWires), .Rin(Rin[4]), .Clock(Clock), .Q(R4));
    regn #(.N(9)) reg_5    (.R(BusWires), .Rin(Rin[5]), .Clock(Clock), .Q(R5));
    regn #(.N(9)) reg_6    (.R(BusWires), .Rin(Rin[6]), .Clock(Clock), .Q(R6));

    pc_counter #(.N(9)) reg_7 (
        .R     (BusWires),
        .L     (Rin[7]),
        .E     (incr_pc),
        .Clock (Clock),
        .Resetn(Resetn),
        .Q     (R7)
    );

    regn #(.N(9)) reg_A    (.R(BusWires), .Rin(Ain),    .Clock(Clock), .Q(A));
    regn #(.N(9)) reg_G    (.R(Sum),      .Rin(Gin),    .Clock(Clock), .Q(G));
    regn #(.N(9)) reg_IR   (.R(DIN),      .Rin(IRin),   .Clock(Clock), .Q(IR));
    regn #(.N(9)) reg_ADDR (.R(BusWires), .Rin(ADDRin), .Clock(Clock), .Q(ADDR));
    regn #(.N(9)) reg_DOUT (.R(BusWires), .Rin(DOUTin), .Clock(Clock), .Q(DOUT));

    addsub #(.N(9)) alu (
        .A     (A),
        .B     (BusWires),
        .AddSub(AddSub),
        .Result(Sum)
    );

    // ------------------------------------------------------------------------
    // Datapath: 10-to-1 Bus Multiplexer
    // ------------------------------------------------------------------------
    always_comb begin
        case ({Rout, Gout, DINout})
            10'b0000_0001_00: BusWires = R0;
            10'b0000_0010_00: BusWires = R1;
            10'b0000_0100_00: BusWires = R2;
            10'b0000_1000_00: BusWires = R3;
            10'b0001_0000_00: BusWires = R4;
            10'b0010_0000_00: BusWires = R5;
            10'b0100_0000_00: BusWires = R6;
            10'b1000_0000_00: BusWires = R7;
            10'b0000_0000_10: BusWires = G;
            10'b0000_0000_01: BusWires = DIN;
            default:          BusWires = 9'd0;
        endcase
    end

endmodule
