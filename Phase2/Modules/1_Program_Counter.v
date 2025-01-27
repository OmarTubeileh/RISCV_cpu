module PC (
    input             clk,      // Clock signal for synchronization
    input             reset,    // Reset signal to initialize the PC
    input             PCWrite,  // Control signal to enable/disable PC update (from HDU)
    input      [63:0] pc_in,    // Input: Next PC value (calculated externally)
    output reg [63:0] pc_out    // Output: Current PC value
);
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      pc_out <= 64'b0;  // If reset is active, set PC to 0
    end else if (PCWrite) begin
      pc_out <= pc_in;  // Update PC only when PCWrite is enabled
    end
  end
endmodule

//<= for synchrounus behavior in sequential circuits