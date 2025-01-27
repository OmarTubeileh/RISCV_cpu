module DataCache (
    input             clk,
    input             reset,
    input      [63:0] address,        // Memory address
    input             mem_read,       // Read enable
    input             mem_write,      // Write enable
    input      [63:0] write_data,     // Data to write
    output reg [63:0] read_data,      // Data read from cache
    output reg        hit,            // Cache hit signal
    input             memory_ready,   // Data memory ready signal
    input      [63:0] memory_data,    // Data from memory
    output reg        memory_request  // Request signal to memory
);

  reg [63:0] cache_data[0:127];  // Cache storage: 128 lines x 64 bits (8 bytes per line)
  reg [55:0] cache_tags[0:127];  // Cache tags
  reg cache_valid[0:127];  // Valid bits

  wire [6:0] index = address[9:3];  // Index (7 bits)
  wire [2:0] offset = address[2:0];  // Offset within block (3 bits)
  wire [55:0] tag = address[63:10];  // Tag (remaining upper bits)

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      integer i;
      for (i = 0; i < 128; i = i + 1) begin
        cache_valid[i] <= 0;
      end
    end else begin
      if (mem_read || mem_write) begin
        if (cache_valid[index] && cache_tags[index] == tag) begin
          hit <= 1;
          if (mem_read) read_data <= cache_data[index];
          if (mem_write) cache_data[index] <= write_data;
        end else begin
          hit <= 0;
          memory_request <= 1;
          if (memory_ready) begin
            memory_request <= 0;
            cache_tags[index] <= tag;
            cache_valid[index] <= 1;
            cache_data[index] <= memory_data;  // Fill block on miss
          end
        end
      end
    end
  end
endmodule
