module tb_ForwardingUnit;

  // Signals
  reg [4:0] RS1_E, RS2_E;  // Source registers in EXE stage
  reg [4:0] RD_M, RD_W;  // Destination registers from MEM and WB stages
  reg RegWriteM, RegWriteW;  // Write enable signals
  wire [1:0] ForwardA, ForwardB;  // Forwarding control signals

  // Instantiate the ForwardingUnit
  ForwardingUnit uut (
      .RS1_E(RS1_E),
      .RS2_E(RS2_E),
      .RD_M(RD_M),
      .RD_W(RD_W),
      .RegWriteM(RegWriteM),
      .RegWriteW(RegWriteW),
      .ForwardA(ForwardA),
      .ForwardB(ForwardB)
  );

  // Test sequence
  initial begin
    $dumpfile("waveform.vcd");  // For waveform generation
    $dumpvars(0, tb_ForwardingUnit);

    // Initialize inputs
    RS1_E = 0;
    RS2_E = 0;
    RD_M = 0;
    RD_W = 0;
    RegWriteM = 0;
    RegWriteW = 0;

    // Test Case 1: No forwarding (default case)
    #10 RS1_E = 5'd1;
    RS2_E = 5'd2;
    RD_M = 5'd3;
    RD_W = 5'd4;
    RegWriteM = 0;
    RegWriteW = 0;
    #10;

    // Test Case 2: Forward from MEM stage to RS1 (ForwardA = 2'b10)
    #10 RS1_E = 5'd3;
    RS2_E = 5'd2;
    RD_M = 5'd3;
    RD_W = 5'd4;
    RegWriteM = 1;
    RegWriteW = 0;
    #10;

    // Test Case 3: Forward from MEM stage to RS2 (ForwardB = 2'b10)
    #10 RS1_E = 5'd1;
    RS2_E = 5'd3;
    RD_M = 5'd3;
    RD_W = 5'd4;
    RegWriteM = 1;
    RegWriteW = 0;
    #10;

    // Test Case 4: Forward from WB stage to RS1 (ForwardA = 2'b01)
    #10 RS1_E = 5'd4;
    RS2_E = 5'd2;
    RD_M = 5'd3;
    RD_W = 5'd4;
    RegWriteM = 0;
    RegWriteW = 1;
    #10;

    // Test Case 5: Forward from WB stage to RS2 (ForwardB = 2'b01)
    #10 RS1_E = 5'd1;
    RS2_E = 5'd4;
    RD_M = 5'd3;
    RD_W = 5'd4;
    RegWriteM = 0;
    RegWriteW = 1;
    #10;

    // Test Case 6: Forward from both MEM and WB (conflicting scenarios)
    #10 RS1_E = 5'd3;
    RS2_E = 5'd4;
    RD_M = 5'd3;
    RD_W = 5'd4;
    RegWriteM = 1;
    RegWriteW = 1;
    #10;

    // Test Case 7: No forwarding when RD_M and RD_W are 0
    #10 RS1_E = 5'd1;
    RS2_E = 5'd2;
    RD_M = 5'd0;
    RD_W = 5'd0;
    RegWriteM = 1;
    RegWriteW = 1;
    #10;

    $finish;
  end

  // Display results
  initial begin
    $monitor(
        "Time: %0t | RS1_E: %d | RS2_E: %d | RD_M: %d | RD_W: %d | RegWriteM: %b | RegWriteW: %b | ForwardA: %b | ForwardB: %b",
        $time, RS1_E, RS2_E, RD_M, RD_W, RegWriteM, RegWriteW, ForwardA, ForwardB);
  end

endmodule
