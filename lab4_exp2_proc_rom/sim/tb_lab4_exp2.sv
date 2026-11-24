`timescale 1ns/1ps

module tb_lab4_exp2;

    logic       MClock;
    logic       PClock;
    logic       Resetn;
    logic       Run;
    logic [8:0] Bus;
    logic       Done;

    int err_cnt = 0;

    lab4_exp2_top #(
        .INIT_FILE_MEM("../mem/my_ROM.mem")
    ) dut (
        .MClock(MClock),
        .PClock(PClock),
        .Resetn(Resetn),
        .Run   (Run),
        .Bus   (Bus),
        .Done  (Done)
    );

    task automatic pulse_mclk();
        #10 MClock = 1'b1;
        #10 MClock = 1'b0;
    endtask

    task automatic pulse_pclk();
        #10 PClock = 1'b1;
        #10 PClock = 1'b0;
    endtask

    task automatic check_eq(input string name, input logic [8:0] actual, input logic [8:0] expected);
        if (actual !== expected) begin
            $error("[FAIL] %0t ns | %s: actual=0x%03h (%03o), expected=0x%03h (%03o)",
                   $time, name, actual, actual, expected, expected);
            err_cnt++;
        end else begin
            $display("[PASS] %0t ns | %s = 0x%03h (%03o, signed=%0d)",
                     $time, name, actual, actual, $signed(actual));
        end
    endtask

    task automatic check_done(input string inst_name);
        if (Done !== 1'b1) begin
            $error("[FAIL] %0t ns | %s: expected Done=1 before final PClock edge, got %b",
                   $time, inst_name, Done);
            err_cnt++;
        end
    endtask

    initial begin
        MClock = 1'b0;
        PClock = 1'b0;
        Resetn = 1'b0;
        Run    = 1'b0;

        #20;
        Resetn = 1'b1;
        Run    = 1'b1;

        // 1) Addr 0: mv R1, R4 (000_001_100 = 014_8)
        pulse_mclk();
        pulse_pclk(); // T0 -> T1 (IR <= 014_8)
        check_eq("Inst 0 IR (mv R1,R4)", dut.u_proc.IR, 9'o014);
        check_done("mv R1,R4");
        pulse_pclk(); // T1 -> T0

        // 2) Addr 1: mv R3, R2 (000_011_010 = 032_8)
        pulse_mclk();
        pulse_pclk(); // T0 -> T1
        check_eq("Inst 1 IR (mv R3,R2)", dut.u_proc.IR, 9'o032);
        check_done("mv R3,R2");
        pulse_pclk(); // T1 -> T0

        // 3) Addr 2..3: mvi R2, #5 (120_8, then 005_8)
        pulse_mclk(); // ROM[2] = 120_8
        pulse_pclk(); // T0 -> T1 (IR <= 120_8)
        check_eq("Inst 2 IR (mvi R2,#5)", dut.u_proc.IR, 9'o120);
        pulse_mclk(); // ROM[3] = 005_8
        check_done("mvi R2,#5");
        pulse_pclk(); // T1 -> T0 (R2 <= 0x005)
        check_eq("After mvi R2,#5 -> R2", dut.u_proc.R2, 9'h005);

        // 4) Addr 4..5: mvi R4, #-6 (140_8, then 772_8 = 0x1FA)
        pulse_mclk(); // ROM[4] = 140_8
        pulse_pclk(); // T0 -> T1
        check_eq("Inst 3 IR (mvi R4,#-6)", dut.u_proc.IR, 9'o140);
        pulse_mclk(); // ROM[5] = 0x1FA (-6)
        check_done("mvi R4,#-6");
        pulse_pclk(); // T1 -> T0 (R4 <= 0x1FA)
        check_eq("After mvi R4,#-6 -> R4", dut.u_proc.R4, 9'h1FA);

        // 5) Addr 6: add R3, R7 (237_8)
        pulse_mclk();
        pulse_pclk(); // T0 -> T1
        check_eq("Inst 4 IR (add R3,R7)", dut.u_proc.IR, 9'o237);
        pulse_pclk(); // T1 -> T2
        pulse_pclk(); // T2 -> T3
        check_done("add R3,R7");
        pulse_pclk(); // T3 -> T0
        check_eq("After add R3,R7 -> R3", dut.u_proc.R3, 9'h000);

        // 6) Addr 7: add R2, R0 (220_8) -> R2(5) + R0(0) = 5
        pulse_mclk();
        pulse_pclk(); // T0 -> T1
        check_eq("Inst 5 IR (add R2,R0)", dut.u_proc.IR, 9'o220);
        pulse_pclk(); // T1 -> T2 (A <= 5)
        pulse_pclk(); // T2 -> T3 (G <= 5)
        check_done("add R2,R0");
        pulse_pclk(); // T3 -> T0 (R2 <= 5)
        check_eq("After add R2,R0 -> A",  dut.u_proc.A,  9'h005);
        check_eq("After add R2,R0 -> G",  dut.u_proc.G,  9'h005);
        check_eq("After add R2,R0 -> R2", dut.u_proc.R2, 9'h005);

        // 7) Addr 8: sub R5, R6 (356_8)
        pulse_mclk();
        pulse_pclk(); // T0 -> T1
        check_eq("Inst 6 IR (sub R5,R6)", dut.u_proc.IR, 9'o356);
        pulse_pclk(); // T1 -> T2
        pulse_pclk(); // T2 -> T3
        check_done("sub R5,R6");
        pulse_pclk(); // T3 -> T0
        check_eq("After sub R5,R6 -> R5", dut.u_proc.R5, 9'h000);

        #20;
        if (err_cnt == 0) begin
            $display("==================================================");
            $display("ALL TESTS PASSED FOR LAB 4 EXP 2 (proc + ROM)!");
            $display("==================================================");
        end else begin
            $fatal(1, "LAB 4 EXP 2 FAILED WITH %0d ERRORS!", err_cnt);
        end
        $stop;
    end

endmodule
