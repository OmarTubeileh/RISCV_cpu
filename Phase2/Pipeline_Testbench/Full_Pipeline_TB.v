module Full_Pipeline_tb;

  // Inputs
  reg clk;
  reg reset;

  // Instantiate the Pipeline Processor
  Full_Pipeline uut (
      .clk  (clk),
      .reset(reset)
  );

  // VCD dump for waveform analysis
  initial begin
    $dumpfile("Full_Pipeline_tb.vcd");
    $dumpvars(0, Full_Pipeline_tb);
  end

  // Intermediate signals for $monitor
  reg [63:0] monitored_PC;
  reg [31:0] monitored_Instruction;

  // Instruction Memory Initialization
  initial begin
    // Initialize instruction memory with the given test instructions
    uut.if_stage.instr_mem.mem[0]  = 8'H93;
    uut.if_stage.instr_mem.mem[1]  = 8'H00;
    uut.if_stage.instr_mem.mem[2]  = 8'H00;
    uut.if_stage.instr_mem.mem[3]  = 8'H01;  // addiw x1 x0 16
    uut.if_stage.instr_mem.mem[4]  = 8'H93;
    uut.if_stage.instr_mem.mem[5]  = 8'H00;
    uut.if_stage.instr_mem.mem[6]  = 8'H10;
    uut.if_stage.instr_mem.mem[7]  = 8'H00;  // addiw x2 x0 8
    uut.if_stage.instr_mem.mem[8]  = 8'H93;
    uut.if_stage.instr_mem.mem[9]  = 8'H00;
    uut.if_stage.instr_mem.mem[10] = 8'H28;
    uut.if_stage.instr_mem.mem[11] = 8'H00;  // addiw x4 x0 10
    uut.if_stage.instr_mem.mem[12] = 8'H93;
    uut.if_stage.instr_mem.mem[13] = 8'H00;
    uut.if_stage.instr_mem.mem[14] = 8'H00;
    uut.if_stage.instr_mem.mem[15] = 8'H00;  // addiw x3 x0 0
    uut.if_stage.instr_mem.mem[16] = 8'HB3;
    uut.if_stage.instr_mem.mem[17] = 8'H6C;
    uut.if_stage.instr_mem.mem[18] = 8'H41;
    uut.if_stage.instr_mem.mem[19] = 8'H50;  // addw x3 x1 x2
    uut.if_stage.instr_mem.mem[20] = 8'H93;
    uut.if_stage.instr_mem.mem[21] = 8'H0F;
    uut.if_stage.instr_mem.mem[22] = 8'HF0;
    uut.if_stage.instr_mem.mem[23] = 8'H00;  // addiw x1 x0 0xFF
    uut.if_stage.instr_mem.mem[24] = 8'H93;
    uut.if_stage.instr_mem.mem[25] = 8'H0E;
    uut.if_stage.instr_mem.mem[26] = 8'HF1;
    uut.if_stage.instr_mem.mem[27] = 8'H00;  // addiw x2 x0 0xF0
    uut.if_stage.instr_mem.mem[28] = 8'H93;
    uut.if_stage.instr_mem.mem[29] = 8'H00;
    uut.if_stage.instr_mem.mem[30] = 8'H22;
    uut.if_stage.instr_mem.mem[31] = 8'H01;  // addiw x4 x0 0
    uut.if_stage.instr_mem.mem[32] = 8'H93;
    uut.if_stage.instr_mem.mem[33] = 8'H03;
    uut.if_stage.instr_mem.mem[34] = 8'HFF;
    uut.if_stage.instr_mem.mem[35] = 8'H01;  // andi x4 x1 0x0F
    uut.if_stage.instr_mem.mem[36] = 8'HB3;
    uut.if_stage.instr_mem.mem[37] = 8'H62;
    uut.if_stage.instr_mem.mem[38] = 8'HF1;
    uut.if_stage.instr_mem.mem[39] = 8'H01;  // xor x7 x1 x2
    uut.if_stage.instr_mem.mem[40] = 8'HB3;
    uut.if_stage.instr_mem.mem[41] = 8'HF0;
    uut.if_stage.instr_mem.mem[42] = 8'HA0;
    uut.if_stage.instr_mem.mem[43] = 8'H01;  // and x3 x1 x2
    uut.if_stage.instr_mem.mem[44] = 8'H93;
    uut.if_stage.instr_mem.mem[45] = 8'H42;
    uut.if_stage.instr_mem.mem[46] = 8'H33;
    uut.if_stage.instr_mem.mem[47] = 8'H00;  // ori x6 x2 0x0A
    uut.if_stage.instr_mem.mem[48] = 8'H93;
    uut.if_stage.instr_mem.mem[49] = 8'HF2;
    uut.if_stage.instr_mem.mem[50] = 8'H32;
    uut.if_stage.instr_mem.mem[51] = 8'H01;  // or x5 x3 x4
  end

  // Clock Generation
  always #5 clk = ~clk;  // 10ns clock period

  // Test Sequence
  initial begin
    // Initialize inputs
    clk   = 0;
    reset = 1;

    // Apply reset
    #10 reset = 0;

    // Run the simulation for a sufficient number of cycles to process all instructions
    #500;

    // Stop the simulation
    $finish;
  end

  // Update intermediate signals with limited sensitivity
  always @(posedge clk) begin
    monitored_PC <= uut.if_stage.PC_F;
    monitored_Instruction <= {
      uut.if_stage.instr_mem.mem[uut.if_stage.PC_F+3],
      uut.if_stage.instr_mem.mem[uut.if_stage.PC_F+2],
      uut.if_stage.instr_mem.mem[uut.if_stage.PC_F+1],
      uut.if_stage.instr_mem.mem[uut.if_stage.PC_F]
    };
  end

  // Monitor Outputs
  initial begin
    $monitor("Time: %d | PC: %h | Instruction: %b", $time, monitored_PC, monitored_Instruction);
  end

endmodule
