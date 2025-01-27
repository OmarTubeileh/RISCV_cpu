`include "6_ALU.v"
`include "adder.v"
`include "Forwarding_Unit.v"

module EXE_Stage (
    input        clk,
    input        reset,
    // Inputs from ID/EX pipeline register
    input        RegWriteE,
    input        ALUSrcE,
    input        MemWriteE,
    MemToRegE,
    MemReadE,
    Mem_ReadE,
    input [ 1:0] MemTypeE,
    input [ 3:0] ALUOpE,     // ALU Control Signal
    input [63:0] RD1_E,      // First operand from Register File
    input [63:0] RD2_E,      // Second operand from Register File
    input [63:0] Imm_E,      // Immediate value
    input [ 4:0] RD_E,       // Destination register
    input [63:0] PCE,        // Program Counter
    input        BEQ_E,      // Branch equal signal
    input        BNE_E,      // Branch not equal signal
    input        JAL_E,      // Jump and link signal
    input        JALR_E,     // Jump and link register signal

    // Forwarding inputs
    input [ 4:0] RS1_E,
    RS2_E,  // Source registers from ID/EX
    input [ 4:0] RD_M,
    RD_W,  // Destination registers from MEM and WB
    input        RegWriteM,
    RegWriteW,  // Write enable signals from MEM and WB
    input [63:0] ALU_ResultM,  // ALU result from MEM stage
    input [63:0] WriteDataW,   // Write-back data from WB stage

    // Outputs to EXE/MEM pipeline register
    output reg        PCSrcE,           // Branch decision
    output reg        RegWriteM_out,
    output reg        MemWriteM_out,
    MemToRegM_out,
    MemReadM_out,
    Mem_ReadM_out,
    output reg [ 1:0] MemTypeM_out,
    output reg [ 4:0] RD_M_out,
    output reg [63:0] WriteDataM_out,
    output reg [63:0] ALU_ResultM_out,
    output reg [63:0] PCTargetE         // Branch target address
);

  // Internal signals
  reg [63:0] SrcA, SrcB;  // ALU operands
  wire [63:0] ALUResult;  // ALU output
  wire        ZeroFlag;  // ALU zero flag
  wire [63:0] BranchTarget;  // Branch target address
  wire [1:0] ForwardA, ForwardB;  // Forwarding control signals

  // Forwarding Unit instantiation
  ForwardingUnit forward_unit (
      .RS1_E(RS1_E),
      .RS2_E(RS2_E),
      .RD_M(RD_M),
      .RD_W(RD_W),
      .RegWriteM(RegWriteM),
      .RegWriteW(RegWriteW),
      .ForwardA(ForwardA),
      .ForwardB(ForwardB)
  );

  // MUX logic for ALU operands (SrcA and SrcB)
  always @(*) begin
    // Forwarding logic for SrcA
    case (ForwardA)
      2'b00:   SrcA = RD1_E;  // No forwarding
      2'b10:   SrcA = ALU_ResultM;  // Forward from MEM stage (ALU-ALU)
      2'b01:   SrcA = WriteDataW;  // Forward from WB stage (MEM-ALU)
      default: SrcA = RD1_E;
    endcase

    // Forwarding logic for SrcB
    case (ForwardB)
      2'b00:   SrcB = (ALUSrcE) ? Imm_E : RD2_E;  // No forwarding
      2'b10:   SrcB = ALU_ResultM;  // Forward from MEM stage (ALU-ALU)
      2'b01:   SrcB = WriteDataW;  // Forward from WB stage (MEM-ALU)
      default: SrcB = RD2_E;
    endcase
  end

  // ALU instantiation
  ALU alu_unit (
      .input1(SrcA),
      .input2(SrcB),
      .alu_control(ALUOpE),
      .result(ALUResult),
      .zero(ZeroFlag)
  );

  // Branch Target Calculation
  Adder branch_adder (
      .A(PCE),
      .B(Imm_E << 1),  // shifted by 1 for branch target calculation (least significant bit (LSB) of the offset is always 0 because instructions are 4 bytes (32 bits) wide, and branch targets are always multiples of 4)
      .Cin(1'b0), // Since we're adding the program counter (PC) and the shifted immediate value, there's no carry from a previous operation
      .Sum(BranchTarget),
      .Cout()  // carry-out from the MSB is not relevant to the target address calculation
  );

  // Branch Decision Logic
  always @(*) begin
    // Calculate the branch target address
    PCTargetE = (JALR_E) ? (SrcA + Imm_E) : BranchTarget;

    // Branch decision logic
    PCSrcE = (BEQ_E && ZeroFlag) || (BNE_E && !ZeroFlag) || JAL_E || JALR_E;
  end

  // Update Pipeline Registers
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      // Reset all pipeline outputs
      PCSrcE <= 0;
      RegWriteM_out <= 0;
      MemWriteM_out <= 0;
      MemToRegM_out <= 0;
      MemReadM_out <= 0;
      RD_M_out <= 0;
      WriteDataM_out <= 0;
      ALU_ResultM_out <= 0;
      PCTargetE <= 0;
      MemTypeM_out <= 0;
      Mem_ReadM_out <= 0;
    end else begin
      // Pass control and data signals to the next stage
      RegWriteM_out <= RegWriteE;
      MemWriteM_out <= MemWriteE;
      MemToRegM_out <= MemToRegE;
      MemReadM_out <= MemReadE;
      MemTypeM_out <= MemTypeE;
      Mem_ReadM_out <= Mem_ReadE;
      RD_M_out <= RD_E;
      WriteDataM_out <= RD2_E;  // Data for memory write
      ALU_ResultM_out <= ALUResult;
    end
  end

endmodule

