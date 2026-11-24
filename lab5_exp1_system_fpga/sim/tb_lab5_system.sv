`timescale 1ns/1ps

// ============================================================================
// Testbench: tb_lab5_system
// Description: Full-system functional verification of Lab 5 (Figure 2 & 3)
//              Uses program_sim.mem (R3=2, R4=2) to verify:
//                1) 2-FF Run synchronizer on SW[9]
//                2) Instruction fetch & execution from 128x9 synchronous RAM
//                3) Address decoding for LEDs register (A8A7 = 01)
//                4) Counter progression on LEDR[8:0]: 0 -> 1 -> 2 -> 3 -> 4
//                5) Pause/Resume via SW[9] and Reset via KEY[0]
// ============================================================================
module tb_lab5_system;

    logic       CLOCK_50;
    logic [0:0] KEY;
    logic [9:9] SW;
    logic [8:0] LEDR;

    int err_cnt = 0;

    lab5_system_top #(
        .INIT_FILE_MEM("../mem/program_sim.mem")
    ) dut (
        .CLOCK_50(CLOCK_50),
        .KEY     (KEY),
        .SW      (SW),
        .LEDR    (LEDR)
    );

    // 50 MHz clock (20 ns period)
    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    task automatic wait_led_value(input logic [8:0] target, input int max_cycles);
        int cyc = 0;
        while (LEDR !== target && cyc < max_cycles) begin
            @(posedge CLOCK_50);
            #1;
            cyc++;
        end
        if (LEDR !== target) begin
            $error("[FAIL] %0t ns | Timeout waiting for LEDR=%0d (actual=%0d)",
                   $time, target, LEDR);
            err_cnt++;
        end else begin
            $display("[PASS] %0t ns | LEDR reached %0d (0x%03h, bin=%09b) after %0d cycles",
                     $time, LEDR, LEDR, LEDR, cyc);
        end
    endtask

    initial begin
        KEY[0] = 1'b0; // Assert active-low Resetn
        SW[9]  = 1'b0; // Run = 0

        repeat (3) @(posedge CLOCK_50);
        #3;
        KEY[0] = 1'b1; // Release Resetn

        repeat (3) @(posedge CLOCK_50);
        if (dut.u_proc.R7 !== 9'd0) begin
            $error("[FAIL] PC should stay 0 while SW[9]=0, got %0d", dut.u_proc.R7);
            err_cnt++;
        end else begin
            $display("[PASS] %0t ns | Processor held idle at PC=0 while SW[9]=0", $time);
        end

        // Assert SW[9] asynchronously (mid-cycle) to test 2-FF synchronizer
        #7;
        SW[9] = 1'b1;

        // Verify counter sequence 0 -> 1 -> 2 -> 3 -> 4 on LEDR[8:0]
        wait_led_value(9'd0, 50);
        wait_led_value(9'd1, 250);
        wait_led_value(9'd2, 250);
        wait_led_value(9'd3, 250);
        wait_led_value(9'd4, 250);

        // Test pause via SW[9] = 0
        #5;
        SW[9] = 1'b0;
        repeat (30) @(posedge CLOCK_50);
        if (LEDR !== 9'd4) begin
            $error("[FAIL] LEDR changed while paused! Expected 4, got %0d", LEDR);
            err_cnt++;
        end else begin
            $display("[PASS] %0t ns | Processor paused cleanly with LEDR=%0d", $time, LEDR);
        end

        // Test resume via SW[9] = 1 -> should continue to 5
        SW[9] = 1'b1;
        wait_led_value(9'd5, 250);

        // Test active-low reset via KEY[0] = 0 -> restarts from 0
        KEY[0] = 1'b0;
        repeat (3) @(posedge CLOCK_50);
        KEY[0] = 1'b1;
        wait_led_value(9'd0, 80);
        wait_led_value(9'd1, 250);

        #40;
        if (err_cnt == 0) begin
            $display("============================================================");
            $display("ALL TESTS PASSED FOR LAB 5 FULL SYSTEM (DE10-Standard)!");
            $display("============================================================");
        end else begin
            $fatal(1, "LAB 5 FULL SYSTEM FAILED WITH %0d ERRORS!", err_cnt);
        end
        $stop;
    end

endmodule
