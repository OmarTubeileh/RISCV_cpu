module ID_EXE_REG (
    input clk,
    input reset,
    input Stall,  // Stall signal from HDU

    // Inputs from ID stage
    input        RegWriteD,
    ALUSrcD,
    MemWriteD,
    MemReadD,
    Mem_ReadD,
    ResultSrcD,
    input [ 1:0] MemTypeD,
    input [ 3:0] ALUOpD,     // ALU operation signal
    input [63:0] RD1_D,      // Read data 1 from Register File
    input [63:0] RD2_D,      // Read data 2 from Register File
    input [63:0] Imm_D,      // Immediate value
    input [ 4:0] RD_D,       // Destination register
    input [63:0] PCD,        // Program Counter value
    input        BEQ_D,
    BNE_D,
    JAL_D,
    JALR_D,  // Branch and jump control signals
    input [ 4:0] RS1_D,
    RS2_D,  // Source registers from ID stage

    // Outputs to EXE stage
    output reg RegWriteE,
    ALUSrcE,
    MemWriteE,
    MemReadE,
    Mem_ReadE,
    ResultSrcE,
    output reg [1:0] MemTypeE,
    output reg [3:0] ALUOpE,
    output reg [63:0] RD1_E,
    output reg [63:0] RD2_E,
    output reg [63:0] Imm_E,
    output reg [4:0] RD_E,
    output reg [63:0] PCE,
    output reg BEQ_E,
    BNE_E,
    JAL_E,
    JALR_E,
    output reg [4:0] RS1_E,
    RS2_E
);

  always @(posedge clk or posedge reset) begin
    if (reset || Stall) begin
      // Clear all outputs to insert a NOP
      RegWriteE <= 0;
      ALUSrcE <= 0;
      MemWriteE <= 0;
      MemReadE <= 0;
      Mem_ReadE <= 0;
      MemTypeE <= 2'b0;
      ResultSrcE <= 0;
      ALUOpE <= 4'b0000;
      RD1_E <= 64'b0;
      RD2_E <= 64'b0;
      Imm_E <= 64'b0;
      RD_E <= 5'b0;
      PCE <= 64'b0;
      BEQ_E <= 0;
      BNE_E <= 0;
      JAL_E <= 0;
      JALR_E <= 0;
      RS1_E <= 5'b0;
      RS2_E <= 5'b0;
    end else begin
      // Normal pipeline operation
      RegWriteE <= RegWriteD;
      ALUSrcE <= ALUSrcD;
      MemWriteE <= MemWriteD;
      MemReadE <= MemReadD;
      Mem_ReadE <= Mem_ReadD;
      MemTypeE <= MemTypeD;
      ResultSrcE <= ResultSrcD;
      ALUOpE <= ALUOpD;
      RD1_E <= RD1_D;
      RD2_E <= RD2_D;
      Imm_E <= Imm_D;
      RD_E <= RD_D;
      PCE <= PCD;
      BEQ_E <= BEQ_D;
      BNE_E <= BNE_D;
      JAL_E <= JAL_D;
      JALR_E <= JALR_D;
      RS1_E <= RS1_D;
      RS2_E <= RS2_D;
    end
  end
endmodule
