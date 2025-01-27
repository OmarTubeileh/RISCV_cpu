// Data Memory Module
// Simulates memory for storing and retrieving data
module DataMemory (
    input             clk,         // Clock signal
    input             mem_read,    // Read enable signal
    input             mem_write,   // Write enable signal
    input      [63:0] address,     // Memory address
    input      [63:0] write_data,  // Data to write
    output reg [63:0] read_data    // Data read from memory
);

  // 8k x 1 byte
  reg [7:0] memory[0:8191];

// Reading from memory
  always @(posedge clk) begin
    if (mem_read) begin
      // Read 64-bit word by assembling 8 consecutive bytes
      read_data <= {
          memory[address],       // Byte 0
          memory[address + 1],   // Byte 1
          memory[address + 2],   // Byte 2
          memory[address + 3],   // Byte 3
          memory[address + 4],   // Byte 4
          memory[address + 5],   // Byte 5
          memory[address + 6],   // Byte 6
          memory[address + 7]    // Byte 7
      };
    end else begin
      read_data = 64'b0; // Default value when read is disabled
    end
  end

  // Writing to memory
  always @(posedge clk) begin
    if (mem_write) begin
      // Write 64-bit word into 8 consecutive bytes
      memory[address]       <= write_data[63:56]; // Byte 0
      memory[address + 1]   <= write_data[55:48]; // Byte 1
      memory[address + 2]   <= write_data[47:40]; // Byte 2
      memory[address + 3]   <= write_data[39:32]; // Byte 3
      memory[address + 4]   <= write_data[31:24]; // Byte 4
      memory[address + 5]   <= write_data[23:16]; // Byte 5
      memory[address + 6]   <= write_data[15:8];  // Byte 6
      memory[address + 7]   <= write_data[7:0];   // Byte 7
    end
  end

endmodule
