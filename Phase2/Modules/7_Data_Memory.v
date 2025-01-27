module DataMemory (
    input             clk,         // Clock signal
    input             mem_read,    // Read enable signal
    input             mem_write,   // Write enable signal
    input      [ 1:0] MemType,     // Memory type
    input      [63:0] address,     // Memory address
    input      [63:0] write_data,  // Data to write
    output reg [63:0] read_data    // Data read from memory
);

  // 8k x 1 byte
  reg [7:0] memory[0:8191];

  // Reading from memory
  always @(posedge clk) begin
    if (mem_read) begin
      case (MemType)
        2'b00:  // Byte (8 bits)
        read_data <= {56'b0, memory[address]};  // Zero-extend to 64 bits
        2'b01:  // Halfword (16 bits)
        read_data <= {48'b0, memory[address], memory[address+1]};  // Zero-extend to 64 bits
        2'b10:  // Word (32 bits)
        read_data <= {
          32'b0, memory[address], memory[address+1], memory[address+2], memory[address+3]
        };  // Zero-extend to 64 bits
        2'b11:  // Doubleword (64 bits)
        read_data <= {
          memory[address],
          memory[address+1],
          memory[address+2],
          memory[address+3],
          memory[address+4],
          memory[address+5],
          memory[address+6],
          memory[address+7]
        };
        default: read_data <= 64'b0;  // Default value
      endcase
    end else begin
      read_data <= 64'b0;  // Default value when read is disabled
    end
  end

  // Writing to memory
  always @(posedge clk) begin
    if (mem_write) begin
      case (MemType)
        2'b00:  // Byte (8 bits)
          memory[address] <= write_data[7:0];  // Write the least significant byte
        2'b01: // Halfword (16 bits)
          begin
            memory[address]   <= write_data[7:0];   // Byte 0 (LSB)
            memory[address+1] <= write_data[15:8];  // Byte 1
          end
        2'b10: // Word (32 bits)
          begin
            memory[address]   <= write_data[7:0];   // Byte 0 (LSB)
            memory[address+1] <= write_data[15:8];  // Byte 1
            memory[address+2] <= write_data[23:16]; // Byte 2
            memory[address+3] <= write_data[31:24]; // Byte 3 (MSB)
          end
        2'b11: // Doubleword (64 bits)
          begin
            memory[address]   <= write_data[7:0];   // Byte 0 (LSB)
            memory[address+1] <= write_data[15:8];  // Byte 1
            memory[address+2] <= write_data[23:16]; // Byte 2
            memory[address+3] <= write_data[31:24]; // Byte 3
            memory[address+4] <= write_data[39:32]; // Byte 4
            memory[address+5] <= write_data[47:40]; // Byte 5
            memory[address+6] <= write_data[55:48]; // Byte 6
            memory[address+7] <= write_data[63:56]; // Byte 7 (MSB)
          end
      endcase
    end
  end

endmodule
