module tb_DataMemory;

  // Signals
  reg         clk;
  reg         mem_read;
  reg         mem_write;
  reg  [ 1:0] MemType;  // Memory type (Byte, Halfword, Word, Doubleword)
  reg  [63:0] address;
  reg  [63:0] write_data;
  wire [63:0] read_data;

  // Instantiate the DataMemory module
  DataMemory uut (
      .clk(clk),
      .mem_read(mem_read),
      .mem_write(mem_write),
      .MemType(MemType),
      .address(address),
      .write_data(write_data),
      .read_data(read_data)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test sequence
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_DataMemory);

    mem_read = 0;
    mem_write = 0;
    MemType = 2'b00;  // Default to Byte access
    address = 0;
    write_data = 0;

    // Wait for initialization
    #10;

    // Test Case 1: Write a doubleword (64 bits) to memory
    mem_write = 1;
    MemType = 2'b11;  // Doubleword
    address = 64'h10;  // Address 0x10
    write_data = 64'hDEADBEEFCAFEBABE;
    #10;

    // Test Case 2: Read back the doubleword
    mem_write = 0;
    mem_read  = 1;
    #10;

    // Test Case 3: Write a word (32 bits) to memory
    mem_read = 0;
    mem_write = 1;
    MemType = 2'b10;  // Word
    address = 64'h20;  // Address 0x20
    write_data = 64'h12345678;
    #10;

    // Test Case 4: Read back the word
    mem_write = 0;
    mem_read  = 1;
    #10;

    // Test Case 5: Write a byte (8 bits) to memory
    mem_read = 0;
    mem_write = 1;
    MemType = 2'b00;  // Byte
    address = 64'h30;  // Address 0x30
    write_data = 64'hAB;
    #10;

    // Test Case 6: Read back the byte
    mem_write = 0;
    mem_read  = 1;
    #10;

    // End simulation
    $finish;
  end

  // Monitor output
  initial begin
    $monitor(
        "Time: %t | Address: %h | Write Data: %h | Read Data: %h | Mem_Read: %b | Mem_Write: %b | MemType: %b",
        $time, address, write_data, read_data, mem_read, mem_write, MemType);
  end

endmodule
