module tb_EXE_Stage;

  // Inputs
  reg clk;
  reg reset;
  reg RegWriteE, ALUSrcE, MemWriteE, MemToRegE, MemReadE, Mem_ReadE;
  reg [1:0] MemTypeE;
  reg [3:0] ALUOpE;
  reg [63:0] RD1_E, RD2_E, Imm_E, PCE;
  reg [4:0] RD_E, RS1_E, RS2_E, RD_M, RD_W;
  reg BEQ_E, BNE_E, JAL_E, JALR_E;
  reg RegWriteM, RegWriteW;
  reg [63:0] ALU_ResultM, WriteDataW;

  // Outputs
  wire PCSrcE;
  wire RegWriteM_out, MemWriteM_out, MemToRegM_out, MemReadM_out, Mem_ReadM_out;
  wire [1:0] MemTypeM_out;
  wire [4:0] RD_M_out;
  wire [63:0] WriteDataM_out, ALU_ResultM_out, PCTargetE;

  // Instantiate the EXE Stage
  EXE_Stage uut (
      .clk(clk),
      .reset(reset),
      .RegWriteE(RegWriteE),
      .ALUSrcE(ALUSrcE),
      .MemWriteE(MemWriteE),
      .MemToRegE(MemToRegE),
      .MemReadE(MemReadE),
      .Mem_ReadE(Mem_ReadE),
      .MemTypeE(MemTypeE),
      .ALUOpE(ALUOpE),
      .RD1_E(RD1_E),
      .RD2_E(RD2_E),
      .Imm_E(Imm_E),
      .PCE(PCE),
      .RD_E(RD_E),
      .BEQ_E(BEQ_E),
      .BNE_E(BNE_E),
      .JAL_E(JAL_E),
      .JALR_E(JALR_E),
      .RS1_E(RS1_E),
      .RS2_E(RS2_E),
      .RD_M(RD_M),
      .RD_W(RD_W),
      .RegWriteM(RegWriteM),
      .RegWriteW(RegWriteW),
      .ALU_ResultM(ALU_ResultM),
      .WriteDataW(WriteDataW),
      .PCSrcE(PCSrcE),
      .RegWriteM_out(RegWriteM_out),
      .MemWriteM_out(MemWriteM_out),
      .MemToRegM_out(MemToRegM_out),
      .MemReadM_out(MemReadM_out),
      .Mem_ReadM_out(Mem_ReadM_out),
      .MemTypeM_out(MemTypeM_out),
      .RD_M_out(RD_M_out),
      .WriteDataM_out(WriteDataM_out),
      .ALU_ResultM_out(ALU_ResultM_out),
      .PCTargetE(PCTargetE)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Test sequence
  initial begin
    $dumpfile("exe_stage_test.vcd");
    $dumpvars(0, tb_EXE_Stage);

    // Initialize inputs
    clk = 0;
    reset = 1;
    RegWriteE = 0;
    ALUSrcE = 0;
    MemWriteE = 0;
    MemToRegE = 0;
    MemReadE = 0;
    Mem_ReadE = 0;
    MemTypeE = 2'b00;
    ALUOpE = 4'b0000;
    RD1_E = 0;
    RD2_E = 0;
    Imm_E = 0;
    PCE = 0;
    RD_E = 0;
    BEQ_E = 0;
    BNE_E = 0;
    JAL_E = 0;
    JALR_E = 0;
    RS1_E = 0;
    RS2_E = 0;
    RD_M = 0;
    RD_W = 0;
    RegWriteM = 0;
    RegWriteW = 0;
    ALU_ResultM = 0;
    WriteDataW = 0;

    // Reset cycle
    #10 reset = 0;

    // Test cases
    // ADD
    RD1_E   = 10;
    RD2_E   = 20;
    ALUOpE  = 4'b0010;
    ALUSrcE = 0;
    Imm_E   = 100;
    #20;
    // BEQ
    RD1_E = 30;
    RD2_E = 30;
    ALUOpE = 4'b0110;
    BEQ_E = 1;
    PCE = 100;
    Imm_E = 8;
    #20;
    // AND
    RD1_E  = 64'hFFFF0000FFFF0000;
    RD2_E  = 64'h0000FFFF0000FFFF;
    ALUOpE = 4'b0000;
    #20;
    // ADD Immediate
    RD1_E   = 50;
    ALUSrcE = 1;
    Imm_E   = 12;
    ALUOpE  = 4'b0010;
    #20;

    $finish;
  end

  // Monitor signals
  initial begin
    $monitor(
        "Time: %t | ALUOpE: %b | SrcA: %d | SrcB: %d | ALU_ResultM: %d | PCSrcE: %b | PCTargetE: %d",
        $time, ALUOpE, uut.SrcA, uut.SrcB, ALU_ResultM_out, PCSrcE, PCTargetE);
  end

endmodule
