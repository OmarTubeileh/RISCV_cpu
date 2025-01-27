module InstructionMemory_tb;

  // Inputs
  reg clk;
  reg [63:0] address;

  // Outputs
  wire [31:0] instruction;

  // Instantiate the Unit Under Test (UUT)
  InstructionMemory uut (
      .clk(clk),
      .address(address),
      .instruction(instruction)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10 ns clock period
  end

  // Test sequence
  initial begin
    // Initialize inputs
    address = 0;

    // Wait for memory initialization
    #10;

    // Test case 1: Fetch instruction at address 0
    address = 16'h0000;
    #10;  // Wait for one clock cycle
    $display("Test 1: Address = 0x%h, Instruction = 0x%h", address, instruction);

    // Test case 2: Fetch instruction at address 4
    address = 16'h0004;
    #10;  // Wait for one clock cycle
    $display("Test 2: Address = 0x%h, Instruction = 0x%h", address, instruction);

    // Test case 3: Fetch instruction at address 8
    address = 16'h0008;
    #10;  // Wait for one clock cycle
    $display("Test 3: Address = 0x%h, Instruction = 0x%h", address, instruction);

    // Test case 4: Fetch instruction at address 12
    address = 16'h000C;
    #10;  // Wait for one clock cycle
    $display("Test 4: Address = 0x%h, Instruction = 0x%h", address, instruction);

    // Test case 5: Fetch instruction at address 16
    address = 16'h0010;
    #10;  // Wait for one clock cycle
    $display("Test 5: Address = 0x%h, Instruction = 0x%h", address, instruction);

    // Test case 6: Unaligned address (address = 5)
    address = 16'h0005;
    #10;  // Wait for one clock cycle
    $display("Test 6 (Unaligned): Address = 0x%h, Instruction = 0x%h", address, instruction);

    // End simulation
    #20;
    $stop;
  end

endmodule
