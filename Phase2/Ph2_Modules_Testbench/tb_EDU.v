module tb_Exception_Detection_Unit;
  reg clk;
  reg reset;
  reg [31:0] instruction;
  reg [63:0] pc;
  wire exception_flag;
  wire [31:0] scause;
  wire [63:0] sepc;

  // Instantiate the DUT (Device Under Test)
  Exception_Detection_Unit uut (
      .clk(clk),
      .reset(reset),
      .instruction(instruction),
      .pc(pc),
      .exception_flag(exception_flag),
      .scause(scause),
      .sepc(sepc)
  );

  // Generate clock signal
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10ns clock period
  end

  // Test stimulus
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_Exception_Detection_Unit);

    // Apply reset
    reset = 1;
    instruction = 32'b0;
    pc = 64'b0;

    #15 reset = 0;

    // Test case 1: Valid instruction, no exceptions
    instruction = 32'b0000000_00000_00000_000_00000_0110011;  // ADD opcode example
    pc = 64'h0000000000000010;  // Aligned PC
    #15;

    // Test case 2: Illegal instruction
    instruction = 32'b1111111_00000_00000_000_00000_1111111;  // Invalid opcode
    pc = 64'h0000000000000020;
    #15;

    // Test case 3: Memory access violation
    instruction = 32'b0000000_00000_00000_010_00000_0000011;  // Load instruction
    pc = 64'h0000000000000031;
    #15;

    // Test case 4: Reset during exception
    reset = 1;
    #15 reset = 0;

    #15 $finish;
  end

  // Monitor the output
  initial begin
    $monitor("Time: %0t | PC: %h | Instruction: %h | Exception Flag: %b | Scause: %h | SEPC: %h",
             $time, pc, instruction, exception_flag, scause, sepc);
  end
endmodule
