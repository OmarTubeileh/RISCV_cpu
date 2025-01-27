module tb_BranchPredictionUnit;

  // Signals
  reg clk;
  reg reset;
  reg [63:0] pc;
  reg branch_resolved;
  reg actual_taken;
  reg [63:0] branch_pc;
  reg [63:0] branch_target_resolved;
  wire predict_taken;
  wire [63:0] target_pc;

  // Instantiate the module under test (MUT)
  BranchPredictionUnit uut (
      .clk(clk),
      .reset(reset),
      .pc(pc),
      .branch_resolved(branch_resolved),
      .actual_taken(actual_taken),
      .branch_pc(branch_pc),
      .branch_target_resolved(branch_target_resolved),
      .predict_taken(predict_taken),
      .target_pc(target_pc)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10 ns clock period
  end

  // Test sequence
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_BranchPredictionUnit);

    // Initialize inputs
    reset = 1;
    pc = 64'b0;
    branch_resolved = 0;
    actual_taken = 0;
    branch_pc = 64'b0;
    branch_target_resolved = 64'b0;

    #10 reset = 0;  // Release reset

    // Test Case 1: Predict weakly not taken after reset
    pc = 64'h100;  // Address aligned to index
    #10;
    $display("Test Case 1 | PC: %h | Predict Taken: %b | Target PC: %h", pc, predict_taken,
             target_pc);

    // Test Case 2: Update with branch taken (weak to strong taken)
    branch_resolved = 1;
    actual_taken = 1;
    branch_pc = 64'h100;
    branch_target_resolved = 64'h200;
    #10 branch_resolved = 0;
    pc = 64'h100;
    #10;
    $display("Test Case 2 | PC: %h | Predict Taken: %b | Target PC: %h", pc, predict_taken,
             target_pc);

    // Test Case 3: Update with branch not taken (strong taken to weak taken)
    branch_resolved = 1;
    actual_taken = 0;
    branch_pc = 64'h100;
    #10 branch_resolved = 0;
    pc = 64'h100;
    #10;
    $display("Test Case 3 | PC: %h | Predict Taken: %b | Target PC: %h", pc, predict_taken,
             target_pc);

    // Test Case 4: Verify new PC index behavior
    pc = 64'h200;
    #10;
    $display("Test Case 4 | PC: %h | Predict Taken: %b | Target PC: %h", pc, predict_taken,
             target_pc);

    // Test Case 5: Saturate to strongly taken
    branch_resolved = 1;
    actual_taken = 1;
    branch_pc = 64'h100;
    repeat (3) begin
      #10 branch_resolved = 0;
      #10 branch_resolved = 1;
    end
    pc = 64'h100;
    #10;
    $display("Test Case 5 | PC: %h | Predict Taken: %b | Target PC: %h", pc, predict_taken,
             target_pc);

    $finish;
  end

  // Monitor outputs
  initial begin
    $monitor(
        "Time: %t | PC: %h | Predict Taken: %b | Target PC: %h | Branch Resolved: %b | Actual Taken: %b",
        $time, pc, predict_taken, target_pc, branch_resolved, actual_taken);
  end

endmodule
