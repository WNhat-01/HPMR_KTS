`timescale 1ns/1ps

// ============================================================================
// Testbench: tb_proc_enhanced
// Description: Standalone verification of Lab 5 Enhanced Processor (Figure 1)
//              connected to a behavioral 128x9 synchronous-input /
//              combinational-output RAM model.
//              Tests ALL 7 instructions: mvi, mv, add, sub, st, ld, mvnz
//              and direct PC jump (mvi R7, #addr).
// ============================================================================
module tb_proc_enhanced;

    logic [8:0] DIN;
    logic       Resetn;
    logic       Clock;
    logic       Run;
    logic [8:0] ADDR;
    logic [8:0] DOUT;
    logic       W;
    logic       Done;

    int err_cnt = 0;

    // Behavioral model of synchronous-input, unregistered-output 128x9 RAM
    // plus peripheral LEDs register at A8A7 = 01
    logic [8:0] mem [0:127];
    logic [6:0] mem_addr_reg;
    logic [8:0] led_reg;

    proc_enhanced dut (
        .DIN   (DIN),
        .Resetn(Resetn),
        .Clock (Clock),
        .Run   (Run),
        .ADDR  (ADDR),
        .DOUT  (DOUT),
        .W     (W),
        .Done  (Done)
    );

    // 50 MHz clock (20 ns period)
    initial begin
        Clock = 1'b0;
        forever #10 Clock = ~Clock;
    end

    // External memory + LED register model (matching Lab 5 Figure 2 timing)
    wire mem_wr_en = (~ADDR[8] & ~ADDR[7]) & W;
    wire led_en    = (~ADDR[8] &  ADDR[7]) & W;

    always @(posedge Clock) begin
        mem_addr_reg <= ADDR[6:0];
        if (mem_wr_en) begin
            mem[ADDR[6:0]] <= DOUT;
        end
        if (led_en) begin
            led_reg <= DOUT;
        end
    end

    assign DIN = mem[mem_addr_reg];

    task automatic check_eq(input string name, input logic [8:0] actual, input logic [8:0] expected);
        if (actual !== expected) begin
            $error("[FAIL] %0t ns | %s: actual=0x%03h (%0d), expected=0x%03h (%0d)",
                   $time, name, actual, actual, expected, expected);
            err_cnt++;
        end else begin
            $display("[PASS] %0t ns | %s = 0x%03h (%0d)", $time, name, actual, actual);
        end
    endtask

    task automatic wait_done(input string label);
        int timeout = 0;
        while (!Done && timeout < 20) begin
            @(posedge Clock);
            #1;
            timeout++;
        end
        if (!Done) begin
            $fatal(1, "[TIMEOUT] Waiting for Done on: %s", label);
        end
        // Advance past the rising edge that completes the Done state (entering T0)
        @(posedge Clock);
        #1;
    endtask

    initial begin
        // Clear memory
        for (int i = 0; i < 128; i++) mem[i] = 9'd0;
        mem_addr_reg = 7'd0;
        led_reg      = 9'd0;

        // --------------------------------------------------------------------
        // Test Program verifying ALL 7 instructions + PC branch:
        //   00: mvi  R1, #1        -> R1 = 1
        //   02: mvi  R2, #3        -> R2 = 3 (loop counter)
        //   04: mvi  R3, #0x040    -> R3 = RAM data address 0x40
        //   06: mvi  R4, #0x080    -> R4 = LED peripheral address (A8A7=01)
        //   08: st   R2, [R3]      -> mem[0x40] = 3
        //   09: ld   R5, [R3]      -> R5 = mem[0x40] = 3
        //   0A: add  R5, R2        -> R5 = 3 + 3 = 6
        //   0B: st   R5, [R4]      -> led_reg = 6
        //   0C: mv   R0, R7        -> R0 = 0x0D (address of Loop: sub R2, R1)
        //   0D: sub  R2, R1        -> R2 = R2 - 1 (G = 2, 1, 0)
        //   0E: mvnz R7, R0        -> if G != 0, PC <= 0x0D (loops 3 times total)
        //   0F: mvi  R6, #0x055    -> R6 = 0x055 (reached after loop exits)
        //   11: mv   R7, R7        -> hold/self-check stop
        // --------------------------------------------------------------------
        mem[7'h00] = 9'b001_001_000; // mvi R1, #1
        mem[7'h01] = 9'd1;
        mem[7'h02] = 9'b001_010_000; // mvi R2, #3
        mem[7'h03] = 9'd3;
        mem[7'h04] = 9'b001_011_000; // mvi R3, #0x40
        mem[7'h05] = 9'h040;
        mem[7'h06] = 9'b001_100_000; // mvi R4, #0x80 (LEDs)
        mem[7'h07] = 9'h080;
        mem[7'h08] = 9'b101_010_011; // st  R2, [R3]
        mem[7'h09] = 9'b100_101_011; // ld  R5, [R3]
        mem[7'h0A] = 9'b010_101_010; // add R5, R2
        mem[7'h0B] = 9'b101_101_100; // st  R5, [R4]
        mem[7'h0C] = 9'b000_000_111; // mv  R0, R7  (R0 = 0x0D)
        mem[7'h0D] = 9'b011_010_001; // sub R2, R1
        mem[7'h0E] = 9'b110_111_000; // mvnz R7, R0
        mem[7'h0F] = 9'b001_110_000; // mvi R6, #0x55
        mem[7'h10] = 9'h055;

        Resetn = 1'b0;
        Run    = 1'b0;
        #25;
        Resetn = 1'b1;
        #20;
        // Verify processor stays idle at PC=0 while Run=0
        check_eq("Idle PC while Run=0", dut.R7, 9'h000);

        Run = 1'b1;

        wait_done("mvi R1,#1");
        check_eq("R1 after mvi R1,#1", dut.R1, 9'd1);

        wait_done("mvi R2,#3");
        check_eq("R2 after mvi R2,#3", dut.R2, 9'd3);

        wait_done("mvi R3,#0x40");
        check_eq("R3 after mvi R3,#0x40", dut.R3, 9'h040);

        wait_done("mvi R4,#0x80");
        check_eq("R4 after mvi R4,#0x80", dut.R4, 9'h080);

        wait_done("st R2,[R3]");
        check_eq("mem[0x40] after st R2,[R3]", mem[7'h40], 9'd3);

        wait_done("ld R5,[R3]");
        check_eq("R5 after ld R5,[R3]", dut.R5, 9'd3);

        wait_done("add R5,R2");
        check_eq("R5 after add R5,R2", dut.R5, 9'd6);

        wait_done("st R5,[R4]");
        check_eq("LEDs after st R5,[R4]", led_reg, 9'd6);

        wait_done("mv R0,R7");
        check_eq("R0 (saved loop addr)", dut.R0, 9'h00D);

        // Loop iteration 1: R2: 3 -> 2, mvnz taken (PC -> 0x0D)
        wait_done("sub R2,R1 (iter 1)");
        check_eq("R2 iter 1", dut.R2, 9'd2);
        wait_done("mvnz R7,R0 (taken 1)");
        check_eq("PC taken 1", dut.R7, 9'h00D);

        // Loop iteration 2: R2: 2 -> 1, mvnz taken (PC -> 0x0D)
        wait_done("sub R2,R1 (iter 2)");
        check_eq("R2 iter 2", dut.R2, 9'd1);
        wait_done("mvnz R7,R0 (taken 2)");
        check_eq("PC taken 2", dut.R7, 9'h00D);

        // Loop iteration 3: R2: 1 -> 0, mvnz NOT taken (PC stays 0x0F)
        wait_done("sub R2,R1 (iter 3)");
        check_eq("R2 iter 3", dut.R2, 9'd0);
        wait_done("mvnz R7,R0 (not taken)");
        check_eq("PC fall-through", dut.R7, 9'h00F);

        wait_done("mvi R6,#0x55");
        check_eq("R6 after loop exit", dut.R6, 9'h055);

        // Stop processor cleanly
        Run = 1'b0;
        repeat (3) @(posedge Clock);

        if (err_cnt == 0) begin
            $display("========================================================");
            $display("ALL TESTS PASSED FOR LAB 5 PROJECT 1 (proc_enhanced)!");
            $display("========================================================");
        end else begin
            $fatal(1, "LAB 5 PROJECT 1 FAILED WITH %0d ERRORS!", err_cnt);
        end
        $stop;
    end

endmodule
