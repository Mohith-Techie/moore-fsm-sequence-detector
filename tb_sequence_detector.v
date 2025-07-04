`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Module Name: tb_sequence_detector
// Description: Self-checking testbench for the Sequence_Detector_MOORE_Verilog.
//
//////////////////////////////////////////////////////////////////////////////////

module tb_sequence_detector;

  // Testbench signals
  reg  clk;
  reg  reset;
  reg  sequence_in;
  wire detector_out;

  integer error_count = 0;

  // Instantiate the Design Under Test (DUT)
  Sequence_Detector_MOORE_Verilog uut (
    .clock(clk),
    .reset(reset),
    .sequence_in(sequence_in),
    .detector_out(detector_out)
  );

  // Clock generation (100MHz clock, 10ns period)
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 5ns high, 5ns low
  end

  // Verification Task
  task check(input expected_output, input [8*256-1:0] message);
    begin
      #1; // Let combinational logic settle after clock edge
      if (detector_out !== expected_output) begin
          $display("FAILED: %s. Output was %b, expected %b", message, detector_out, expected_output);
          error_count = error_count + 1;
      end else begin
          $display("PASSED: %s. Output is correct.", message);
      end
    end
  endtask

  // Test sequence and verification logic
  initial begin
    $display("========================================");
    $display(" Starting Testbench... ");
    $display("========================================");

    // 1. Apply Reset
    reset = 1;
    sequence_in = 0;
    @(posedge clk);
    @(posedge clk);
    reset = 0;
    $display("\nINFO: Reset finished.");

    // --- Test Case 1: The target sequence "1011" ---
    $display("\n--- Testing sequence '1011' ---");

    // Input sequence: 1 0 1 1
    @(posedge clk) sequence_in <= 1; check(0, "After first '1', output should be 0");
    @(posedge clk) sequence_in <= 0; check(0, "After '10', output should be 0");
    @(posedge clk) sequence_in <= 1; check(0, "After '101', output should be 0");
    @(posedge clk) sequence_in <= 1; check(0, "After '1011', output should still be 0 (Moore FSM)");
    @(posedge clk) sequence_in <= 0; check(1, "After '1011', output MUST be 1 (Moore FSM: output asserted one clock after sequence)");
    @(posedge clk) sequence_in <= 0; check(0, "After sequence, output must return to 0");

    // --- Test Case 2: A longer string with the sequence inside ---
    $display("\n--- Testing sequence '010110' ---");
    @(posedge clk) sequence_in <= 0; check(0, "After '...0'");
    @(posedge clk) sequence_in <= 1; check(0, "After '...01'");
    @(posedge clk) sequence_in <= 0; check(0, "After '...010'");
    @(posedge clk) sequence_in <= 1; check(0, "After '...0101'");
    @(posedge clk) sequence_in <= 1; check(0, "After '...01011', output should still be 0 (Moore FSM)");
    @(posedge clk) sequence_in <= 0; check(1, "After '...01011', output MUST be 1 (Moore FSM: output asserted one clock after sequence)");
    @(posedge clk) sequence_in <= 0; check(0, "After '...010110', output MUST be 0");

    // Final Report
    $display("\n========================================");
    if (error_count == 0) begin
      $display("  ALL TESTS PASSED! Congratulations!  ");
    end else begin
      $display("  SIMULATION FAILED! Found %0d error(s).", error_count);
    end
    $display("========================================");
    $finish;
  end

endmodule