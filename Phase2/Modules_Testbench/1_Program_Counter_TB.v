module tb_PC;

  // Signals
  reg         clk;
  reg         reset;
  reg         PCWrite;  // Control signal for enabling PC update
  reg  [63:0] pc_in;
  wire [63:0] pc_out;

  // Instantiate the PC module
  PC uut (
      .clk    (clk),
      .reset  (reset),
      .PCWrite(PCWrite),  // Connect the PCWrite signal
      .pc_in  (pc_in),
      .pc_out (pc_out)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test sequences
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_PC);

    reset   = 0;
    PCWrite = 0;  // Disable PC update initially
    pc_in   = 64'd0;
    #10 reset = 1;  // Apply reset
    #10 reset = 0;  // Release reset

    // Test case 1: Enable PCWrite and update PC
    PCWrite = 1;
    pc_in   = 64'd4;
    #10;

    // Test case 2: Update PC to a new value
    pc_in = 64'd8;
    #10;

    // Test case 3: Disable PCWrite (PC should hold its value)
    PCWrite = 0;
    pc_in   = 64'd16;  // This should not update PC and should give 0
    #10;

    // Test case 4: Reset the PC
    reset = 1;
    #10 reset = 0;

    $finish;
  end

  // Monitor signals
  initial begin
    $monitor("Time: %t | reset: %b | PCWrite: %b | pc_in: %d | pc_out: %d", $time, reset, PCWrite,
             pc_in, pc_out);
  end

endmodule
