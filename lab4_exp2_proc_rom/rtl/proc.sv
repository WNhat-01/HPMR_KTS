// ============================================================================
// Module: proc
// Description: Lab 4 Simple 9-bit Processor (reused in Experiment 2)
// ============================================================================
module proc (
    input  logic [8:0] DIN,
    input  logic       Resetn,
    input  logic       Clock,
    input  logic       Run,
    output logic       Done,
    output logic [8:0] BusWires
);

    typedef enum logic [1:0] {
        T0 = 2'b00,
        T1 = 2'b01,
        T2 = 2'b10,
        T3 = 2'b11
    } state_t;

    localparam logic [2:0] OP_MV  = 3'b000;
    localparam logic [2:0] OP_MVI = 3'b001;
    localparam logic [2:0] OP_ADD = 3'b010;
    localparam logic [2:0] OP_SUB = 3'b011;

    state_t Tstep_Q, Tstep_D;

    logic [8:0] IR;
    logic [2:0] I;
    logic [7:0] Xreg, Yreg;

    logic       IRin;
    logic [7:0] Rin, Rout;
    logic       Ain, Gin, Gout, DINout, AddSub;

    logic [8:0] R0, R1, R2, R3, R4, R5, R6, R7;
    logic [8:0] A, G, Sum;

    assign I = IR[8:6];
    dec3to8 decX (.W(IR[5:3]), .En(1'b1), .Y(Xreg));
    dec3to8 decY (.W(IR[2:0]), .En(1'b1), .Y(Yreg));

    always_comb begin
        case (Tstep_Q)
            T0:      Tstep_D = (!Run) ? T0 : T1;
            T1:      Tstep_D = (Done) ? T0 : T2;
            T2:      Tstep_D = T3;
            T3:      Tstep_D = T0;
            default: Tstep_D = T0;
        endcase
    end

    always_comb begin
        IRin   = 1'b0;
        Rin    = 8'b0000_0000;
        Rout   = 8'b0000_0000;
        Ain    = 1'b0;
        Gin    = 1'b0;
        Gout   = 1'b0;
        DINout = 1'b0;
        AddSub = 1'b0;
        Done   = 1'b0;

        case (Tstep_Q)
            T0: begin
                IRin = 1'b1;
            end
            T1: begin
                case (I)
                    OP_MV: begin
                        Rout = Yreg;
                        Rin  = Xreg;
                        Done = 1'b1;
                    end
                    OP_MVI: begin
                        DINout = 1'b1;
                        Rin    = Xreg;
                        Done   = 1'b1;
                    end
                    OP_ADD, OP_SUB: begin
                        Rout = Xreg;
                        Ain  = 1'b1;
                    end
                    default: begin
                        Done = 1'b1;
                    end
                endcase
            end
            T2: begin
                case (I)
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
                    default: ;
                endcase
            end
            T3: begin
                case (I)
                    OP_ADD, OP_SUB: begin
                        Gout = 1'b1;
                        Rin  = Xreg;
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

    always_ff @(posedge Clock, negedge Resetn) begin
        if (!Resetn) Tstep_Q <= T0;
        else         Tstep_Q <= Tstep_D;
    end

    regn #(.N(9)) reg_0  (.R(BusWires), .Rin(Rin[0]), .Clock(Clock), .Q(R0));
    regn #(.N(9)) reg_1  (.R(BusWires), .Rin(Rin[1]), .Clock(Clock), .Q(R1));
    regn #(.N(9)) reg_2  (.R(BusWires), .Rin(Rin[2]), .Clock(Clock), .Q(R2));
    regn #(.N(9)) reg_3  (.R(BusWires), .Rin(Rin[3]), .Clock(Clock), .Q(R3));
    regn #(.N(9)) reg_4  (.R(BusWires), .Rin(Rin[4]), .Clock(Clock), .Q(R4));
    regn #(.N(9)) reg_5  (.R(BusWires), .Rin(Rin[5]), .Clock(Clock), .Q(R5));
    regn #(.N(9)) reg_6  (.R(BusWires), .Rin(Rin[6]), .Clock(Clock), .Q(R6));
    regn #(.N(9)) reg_7  (.R(BusWires), .Rin(Rin[7]), .Clock(Clock), .Q(R7));

    regn #(.N(9)) reg_A  (.R(BusWires), .Rin(Ain),    .Clock(Clock), .Q(A));
    regn #(.N(9)) reg_G  (.R(Sum),      .Rin(Gin),    .Clock(Clock), .Q(G));
    regn #(.N(9)) reg_IR (.R(DIN),      .Rin(IRin),   .Clock(Clock), .Q(IR));

    addsub #(.N(9)) alu (
        .A     (A),
        .B     (BusWires),
        .AddSub(AddSub),
        .Result(Sum)
    );

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
