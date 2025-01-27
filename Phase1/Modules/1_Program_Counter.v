// Program Counter Module ~ Keeps track of the address of the current instruction

module PC (
    input             clk,    // Clock signal for synchronization
    input             reset,  // Reset signal to initialize the PC
    input      [63:0] pc_in,  // Input: Next PC value (calculated externally)
    output reg [63:0] pc_out  // Output: Current PC value
);
  // Sequential logic triggered on the positive edge of the clock or reset signal
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      pc_out <= 64'b0;  // If reset is active, set PC to 0
    end else begin
      pc_out <= pc_in;  // If reset is not active, update PC with the input value
    end
  end
endmodule
