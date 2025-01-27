module tb_IF_Stage;

  // Signals
  reg clk;
  reg reset;
  reg PCSrc_E;
  reg [63:0] PC_Target_E;
  reg branch_resolved;
  reg actual_taken;
  reg [63:0] branch_pc;
  reg [63:0] branch_target_resolved;
  reg PCWrite;
  wire [63:0] PC_D;
  wire [31:0] instruction_D;

  // Instantiate the module under test 
  IF_Stage uut (
      .clk(clk),
      .reset(reset),
      .PCSrc_E(PCSrc_E),
      .PC_Target_E(PC_Target_E),
      .branch_resolved(branch_resolved),
      .actual_taken(actual_taken),
      .branch_pc(branch_pc),
      .branch_target_resolved(branch_target_resolved),
      .PCWrite(PCWrite),
      .PC_D(PC_D),
      .instruction_D(instruction_D)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10 ns clock period
  end

  // Test sequence
  initial begin
    $dumpfile("IF_Stage_waveform.vcd");  // Dump waveform for viewing
    $dumpvars(0, tb_IF_Stage);

    // Initialize signals
    reset                  = 1;  // Assert reset
    PCSrc_E                = 0;  // Default to sequential fetch
    PC_Target_E            = 64'd0;  // Default branch target
    branch_resolved        = 0;
    actual_taken           = 0;
    branch_pc              = 64'd0;
    branch_target_resolved = 64'd0;
    PCWrite                = 1;

    #10 reset = 0;  // wait 10 ns

    // Test case 1: Sequential fetch
    PCSrc_E = 0;
    #20;  // Wait for two cycles

    // Test case 2: Branch taken
    branch_resolved = 1;
    actual_taken = 1;
    branch_pc = 64'd8;
    branch_target_resolved = 64'd16;
    PCSrc_E = 1;
    PC_Target_E = 64'd16;  // Jump to address 16
    #10;
    PCSrc_E = 0;  // Back to sequential
    branch_resolved = 0;
    actual_taken = 0;
    #20;

    // Test case 3: Stall PC updates
    PCWrite = 0;  // Disable PC updates
    #20;
    PCWrite = 1;  // Re-enable PC updates
    #20;

    // Test case 4: Reset during operation
    reset = 1;
    #10 reset = 0;

    $finish;  // End simulation
  end

  // Monitor results
  initial begin
    $monitor(
        "Time: %0t | Reset: %b | PCSrc_E: %b | PC_Target_E: %h | branch_resolved: %b | actual_taken: %b | PCWrite: %b | PC_D: %h | Instruction_D: %h",
        $time, reset, PCSrc_E, PC_Target_E, branch_resolved, actual_taken, PCWrite, PC_D,
        instruction_D);
  end

endmodule
