`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Module Name: Sequence_Detector_MOORE_Verilog
// Description: Moore FSM to detect non-overlapping "1011" sequence.
//
//////////////////////////////////////////////////////////////////////////////////

module Sequence_Detector_MOORE_Verilog (
  input  wire clock,
  input  wire reset,
  input  wire sequence_in,
  output wire detector_out
);

  // State definitions
  localparam [2:0] S_IDLE       = 3'b000,
                   S_GOT_1      = 3'b001,
                   S_GOT_10     = 3'b010,
                   S_GOT_101    = 3'b011,
                   S_GOT_1011   = 3'b100;

  reg [2:0] current_state, next_state;

  // Synchronous State Register
  always @(posedge clock or posedge reset) begin
    if (reset) begin
      current_state <= S_IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  // Combinational Next State Logic
  always @(*) begin
    case (current_state)
      S_IDLE:     next_state = sequence_in ? S_GOT_1 : S_IDLE;
      S_GOT_1:    next_state = sequence_in ? S_GOT_1 : S_GOT_10;
      S_GOT_10:   next_state = sequence_in ? S_GOT_101 : S_IDLE;
      S_GOT_101:  next_state = sequence_in ? S_GOT_1011 : S_GOT_10;
      S_GOT_1011: next_state = sequence_in ? S_GOT_1 : S_GOT_10;
      default:    next_state = S_IDLE;
    endcase
  end

  // Moore Output Logic: output is 1 only in S_GOT_1011
  assign detector_out = (current_state == S_GOT_1011);

endmodule