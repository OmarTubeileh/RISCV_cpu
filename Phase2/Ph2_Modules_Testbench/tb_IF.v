module tb_IF_Stage;

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

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_IF_Stage);

    // Initialize inputs
    reset = 1;
    PCSrc_E = 0;
    PC_Target_E = 0;
    branch_resolved = 0;
    actual_taken = 0;
    branch_pc = 0;
    branch_target_resolved = 0;
    PCWrite = 1;

    #10 reset = 0;

    // Test case 1: Normal sequential fetch
    PCSrc_E         = 0;  // No branch decision
    PC_Target_E     = 64'h0;  // No target address
    branch_resolved = 0;
    PCWrite         = 1;
    #20;

    // Test case 2: Branch prediction - branch taken
    branch_pc              = 64'h4;  // Example branch PC
    branch_target_resolved = 64'h20;  // Predicted target address
    branch_resolved        = 1;
    actual_taken           = 1;
    PCSrc_E                = 1;
    PC_Target_E            = 64'h20;
    #20;

    // Test case 3: Branch prediction - misprediction
    branch_resolved = 1;
    actual_taken    = 0;  // Branch was not taken
    PCSrc_E         = 1;  // Correct target
    PC_Target_E     = 64'h8;  // Sequential PC
    #20;

    // Test case 4: Pipeline stall (PCWrite = 0)
    PCWrite = 0;  // Disable PC updates
    #20;

    // Test case 5: Resume pipeline
    PCWrite     = 1;
    PCSrc_E     = 0;  // Resume normal execution
    PC_Target_E = 64'h10;
    #20;

    $finish;
  end

  // Monitor results
  initial begin
    $monitor("Time: %t | PC: %h | Instruction: %h | PCSrc: %b | PCWrite: %b", $time, PC_D,
             instruction_D, PCSrc_E, PCWrite);
  end

endmodule
