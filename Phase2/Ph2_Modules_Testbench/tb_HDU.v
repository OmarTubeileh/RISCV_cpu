module tb_HazardDetectionUnit;

  // Signals
  reg  [4:0] ID_EX_Rd;  // Destination register from EXE stage
  reg        ID_EX_MemRead;  // Memory read enable from EXE stage
  reg        ID_EX_RegWrite;  // Register write enable from EXE stage
  reg        branch_taken_ID;  // Branch decision from ID stage
  reg  [4:0] IF_ID_Rs1;  // Source register 1 from ID stage
  reg  [4:0] IF_ID_Rs2;  // Source register 2 from ID stage

  wire       PCWrite;  // Control signal for PC updates
  wire       IF_ID_Write;  // Control signal for IF/ID register updates
  wire       Stall;  // Stall signal for ID/EX pipeline

  // Instantiate the module under test (MUT)
  HazardDetectionUnit uut (
      .ID_EX_Rd(ID_EX_Rd),
      .ID_EX_MemRead(ID_EX_MemRead),
      .ID_EX_RegWrite(ID_EX_RegWrite),
      .branch_taken_ID(branch_taken_ID),
      .IF_ID_Rs1(IF_ID_Rs1),
      .IF_ID_Rs2(IF_ID_Rs2),
      .PCWrite(PCWrite),
      .IF_ID_Write(IF_ID_Write),
      .Stall(Stall)
  );

  // Clock generation not required for this module, as it is purely combinational

  // Test sequence
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_HazardDetectionUnit);

    // Initialize inputs
    ID_EX_Rd = 0;
    ID_EX_MemRead = 0;
    ID_EX_RegWrite = 0;
    branch_taken_ID = 0;
    IF_ID_Rs1 = 0;
    IF_ID_Rs2 = 0;

    // Test case 1: No hazard
    #10;
    $display("TC1: No Hazard");
    $display("  Expected: PCWrite=1, IF_ID_Write=1, Stall=0");
    $display("  Actual:   PCWrite=%b, IF_ID_Write=%b, Stall=%b", PCWrite, IF_ID_Write, Stall);

    // Test case 2: Load-use hazard
    ID_EX_Rd = 5'b00001;  // EXE stage writes to r1
    ID_EX_MemRead = 1;  // Memory read in EXE stage
    IF_ID_Rs1 = 5'b00001;  // ID stage uses r1
    #10;
    $display("TC2: Load-Use Hazard");
    $display("  Expected: PCWrite=0, IF_ID_Write=0, Stall=1");
    $display("  Actual:   PCWrite=%b, IF_ID_Write=%b, Stall=%b", PCWrite, IF_ID_Write, Stall);

    // Test case 3: Control hazard
    ID_EX_MemRead = 0;
    branch_taken_ID = 1;  // Branch is taken
    IF_ID_Rs1 = 5'b00000;
    IF_ID_Rs2 = 5'b00000;
    #10;
    $display("TC3: Control Hazard");
    $display("  Expected: PCWrite=0, IF_ID_Write=0, Stall=1");
    $display("  Actual:   PCWrite=%b, IF_ID_Write=%b, Stall=%b", PCWrite, IF_ID_Write, Stall);

    // Test case 4: No dependency (Normal flow)
    branch_taken_ID = 0;
    ID_EX_Rd = 5'b00010;  // EXE stage writes to r2
    ID_EX_MemRead = 0;
    IF_ID_Rs1 = 5'b00001;  // ID stage uses r1 (no conflict)
    IF_ID_Rs2 = 5'b00011;  // ID stage uses r3 (no conflict)
    #10;
    $display("TC4: No Dependency");
    $display("  Expected: PCWrite=1, IF_ID_Write=1, Stall=0");
    $display("  Actual:   PCWrite=%b, IF_ID_Write=%b, Stall=%b", PCWrite, IF_ID_Write, Stall);

    $finish;
  end

  // Display results
  initial begin
    $monitor(
        "Time: %0t | ID_EX_Rd=%b | IF_ID_Rs1=%b | IF_ID_Rs2=%b | PCWrite=%b | IF_ID_Write=%b | Stall=%b",
        $time, ID_EX_Rd, IF_ID_Rs1, IF_ID_Rs2, PCWrite, IF_ID_Write, Stall);
  end

endmodule
