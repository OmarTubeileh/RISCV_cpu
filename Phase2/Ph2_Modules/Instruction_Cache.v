module InstructionCache (
    input             clk,
    input             reset,
    input      [63:0] address,        // Address from PC
    output reg [31:0] instruction,    // Instruction output
    output reg        hit,            // Cache hit signal
    input             memory_ready,   // Instruction memory ready signal
    input      [31:0] memory_data,    // Data from instruction memory
    output reg        memory_request  // Request signal to memory
);

  reg [127:0] cache_data[0:255];  // Cache storage: 256 lines x 128 bits (16 bytes per line)
  reg [55:0] cache_tags[0:255];  // Cache tags
  reg cache_valid[0:255];  // Valid bits

  wire [7:0] index = address[11:4];  // Index (8 bits)
  wire [3:0] offset = address[3:0];  // Offset within block (4 bits)
  wire [55:0] tag = address[63:12];  // Tag (remaining upper bits)

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      integer i;
      for (i = 0; i < 256; i = i + 1) begin
        cache_valid[i] <= 0;
      end
    end else begin
      if (cache_valid[index] && cache_tags[index] == tag) begin
        hit <= 1;
        case (offset[3:2])  // Select word within block
          2'b00: instruction <= cache_data[index][31:0];
          2'b01: instruction <= cache_data[index][63:32];
          2'b10: instruction <= cache_data[index][95:64];
          2'b11: instruction <= cache_data[index][127:96];
        endcase
      end else begin
        hit <= 0;
        memory_request <= 1;
        if (memory_ready) begin
          memory_request <= 0;
          cache_tags[index] <= tag;
          cache_valid[index] <= 1;
          cache_data[index] <= {memory_data, cache_data[index][127:32]};  // Example for 4-word fill
        end
      end
    end
  end
endmodule
