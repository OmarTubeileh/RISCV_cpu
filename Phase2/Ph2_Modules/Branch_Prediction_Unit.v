module BranchPredictionUnit (
    input             clk,
    input             reset,
    input      [63:0] pc,                      // 64-bit Program Counter (PC) for indexing
    input             branch_resolved,         // Indicates branch resolution
    input             actual_taken,            // Actual branch outcome
    input      [63:0] branch_pc,               // PC of the resolved branch instruction
    input      [63:0] branch_target_resolved,  // Resolved branch target address
    output reg        predict_taken,           // Predicted branch outcome
    output reg [63:0] target_pc                // Predicted branch target address
);

  reg [1:0] prediction_table[0:255];  // 2-bit saturating counters, size 256
  wire [7:0] index = pc[9:2];  // Index into prediction table (8 bits)

  // Prediction Logic
  always @(*) begin
    // Predict based on the counter value in the table
    predict_taken = (prediction_table[index] >= 2'b10);  // Taken if 10 or 11
    target_pc = branch_target_resolved;  // Provide resolved target if needed
  end

  // Update Logic
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      integer i;
      // Initialize prediction table to weakly not taken
      for (i = 0; i < 256; i = i + 1) prediction_table[i] <= 2'b01;
    end else if (branch_resolved) begin
      // Update the prediction table based on actual outcome
      if (actual_taken) begin
        if (prediction_table[branch_pc[9:2]] != 2'b11)
          prediction_table[branch_pc[9:2]] <= prediction_table[branch_pc[9:2]] + 1;
      end else begin
        if (prediction_table[branch_pc[9:2]] != 2'b00)
          prediction_table[branch_pc[9:2]] <= prediction_table[branch_pc[9:2]] - 1;
      end
    end
  end

endmodule

// Prediction Logic: Uses the lower bits of the PC (pc[9:2]) to index into a prediction table bcs instructions are word-aligned (divisible by 4) so bits [1:0] are always zero (8-bits because we have 255 entires in the prediction table)
// Update Logic: Adjusts the 2-bit counter for each entry based on whether the branch was actually taken or not (actual_taken).
// Initialization: On reset, initializes all entries in the table to weakly not taken (2'b01).
