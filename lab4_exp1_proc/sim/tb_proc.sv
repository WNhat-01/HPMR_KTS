`timescale 1ns/1ps

module tb_proc;

    logic [8:0] DIN;
    logic       Resetn;
    logic       Clock;
    logic       Run;
    logic       Done;
    logic [8:0] BusWires;

    int err_cnt = 0;

    proc dut (
        .DIN     (DIN),
        .Resetn  (Resetn),
        .Clock   (Clock),
        .Run     (Run),
        .Done    (Done),
        .BusWires(BusWires)
    );

    // 50 MHz clock (20 ns period): rising edges at 10, 30, 50, 70, ... ns
    initial begin
        Clock = 1'b0;
        forever #10 Clock = ~Clock;
    end

    task automatic check_eq(input string name, input logic [8:0] actual, input logic [8:0] expected);
        if (actual !== expected) begin
            $error("[FAIL] %0t ns | %s: actual=0x%03h (%03o), expected=0x%03h (%03o)",
                   $time, name, actual, actual, expected, expected);
            err_cnt++;
        end else begin
            $display("[PASS] %0t ns | %s = 0x%03h (signed=%0d)", $time, name, actual, $signed(actual));
        end
    endtask

    initial begin
        DIN    = 9'o000;
        Resetn = 1'b0;
        Run    = 1'b0;

        // Release reset before 2nd rising edge (at 30ns), matching Figure 2
        #15;
        Resetn = 1'b1;

        // --------------------------------------------------------------------
        // Test 1: mvi R0, #5  (matches Lab 4 Figure 2)
        //   30ns edge: IR <= 9'o100 (001_000_000), T0 -> T1
        //   50ns edge: R0 <= 9'o005 (0x005),       T1 -> T0
        // --------------------------------------------------------------------
        #5; // t = 20ns
        DIN = 9'o100; // mvi R0, #D
        Run = 1'b1;
        @(posedge Clock); // t = 30ns
        #2;
        DIN = 9'o005; // #5
        Run = 1'b0;
        @(posedge Clock); // t = 50ns
        #2;
        check_eq("After mvi R0,#5 -> R0", dut.R0, 9'h005);

        // --------------------------------------------------------------------
        // Test 2: mv R1, R0  (matches Lab 4 Figure 2)
        //   70ns edge: IR <= 9'o010 (000_001_000), T0 -> T1
        //   90ns edge: R1 <= R0 (0x005),           T1 -> T0
        // --------------------------------------------------------------------
        #8; // t = 60ns
        DIN = 9'o010; // mv R1, R0
        Run = 1'b1;
        @(posedge Clock); // t = 70ns
        #2;
        Run = 1'b0;
        @(posedge Clock); // t = 90ns
        #2;
        check_eq("After mv R1,R0 -> R1", dut.R1, 9'h005);

        // --------------------------------------------------------------------
        // Test 3: add R0, R1  (matches Lab 4 Figure 2)
        //   110ns: IR <= 9'o201 (010_000_001), T0 -> T1
        //   130ns: A  <= R0 (0x005),           T1 -> T2
        //   150ns: G  <= A + R1 (0x00A),       T2 -> T3
        //   170ns: R0 <= G (0x00A),            T3 -> T0
        // --------------------------------------------------------------------
        #8; // t = 100ns
        DIN = 9'o201; // add R0, R1
        Run = 1'b1;
        @(posedge Clock); // t = 110ns
        #2;
        Run = 1'b0;
        repeat (3) @(posedge Clock); // 130, 150, 170ns
        #2;
        check_eq("After add R0,R1 -> A",  dut.A,  9'h005);
        check_eq("After add R0,R1 -> G",  dut.G,  9'h00A);
        check_eq("After add R0,R1 -> R0", dut.R0, 9'h00A);

        // --------------------------------------------------------------------
        // Test 4: sub R0, R0  (matches Lab 4 Figure 2)
        //   190ns: IR <= 9'o300 (011_000_000), T0 -> T1
        //   210ns: A  <= R0 (0x00A),           T1 -> T2
        //   230ns: G  <= A - R0 (0x000),       T2 -> T3
        //   250ns: R0 <= G (0x000),            T3 -> T0
        // --------------------------------------------------------------------
        #8; // t = 180ns
        DIN = 9'o300; // sub R0, R0
        Run = 1'b1;
        @(posedge Clock); // t = 190ns
        #2;
        Run = 1'b0;
        repeat (3) @(posedge Clock); // 210, 230, 250ns
        #2;
        check_eq("After sub R0,R0 -> G",  dut.G,  9'h000);
        check_eq("After sub R0,R0 -> R0", dut.R0, 9'h000);

        // --------------------------------------------------------------------
        // Test 5 (Extra signed arithmetic check): mvi R2, #-6; add R1, R2
        //   R1 = 5, R2 = -6 (0x1FA) -> R1 + R2 = -1 (0x1FF)
        // --------------------------------------------------------------------
        #8;
        DIN = 9'b001_010_000; // mvi R2, #D
        Run = 1'b1;
        @(posedge Clock);
        #2;
        DIN = 9'b1_1111_1010; // -6 in 9-bit two's complement (0x1FA)
        Run = 1'b0;
        @(posedge Clock);
        #2;
        check_eq("After mvi R2,#-6 -> R2", dut.R2, 9'h1FA);

        #8;
        DIN = 9'b010_001_010; // add R1, R2
        Run = 1'b1;
        @(posedge Clock);
        #2;
        Run = 1'b0;
        repeat (3) @(posedge Clock);
        #2;
        check_eq("After add R1,R2 (5 + -6) -> R1", dut.R1, 9'h1FF);

        // Summary
        #20;
        if (err_cnt == 0) begin
            $display("==============================================");
            $display("ALL TESTS PASSED FOR LAB 4 EXP 1 (proc)!");
            $display("==============================================");
        end else begin
            $fatal(1, "LAB 4 EXP 1 FAILED WITH %0d ERRORS!", err_cnt);
        end
        $stop;
    end

endmodule
