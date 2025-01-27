`include "1_Program_Counter.v"
`include "2_Instruction_Memory.v"
`include "Mux.v"
`include "Branch_Prediction_Unit.v"

module IF_Stage (
    input clk,
    input reset,

    input PCSrc_E,  // Branch decision from EXE stage
    input [63:0] PC_Target_E,  // Resolved target address from EXE stage (calculated target address where the branch instruction will jump if the branch condition is satisfied)
    input branch_resolved,  // Indicates branch resolution in EXE stage, indicates completion of branch besolution
    input actual_taken,  // REDUDANT (same as PCSrc_E)

    input [63:0] branch_pc,  // PC of the branch instruction (BEQ/BNE adress)
    input [63:0] branch_target_resolved,  // REDUDANT (same as PC_Target_E)

    input PCWrite,  // Control signal from HDU to enable/disable PC updates

    output wire [63:0] PC_D,  // Program Counter output for the next stage
    output wire [31:0] instruction_D  // Instruction output for the next stage
);

  wire [63:0] PC_F;  // Next PC value (from mux) (may point to either the next sequential instruction address (PC_4F) or a branch/jump target, depending on the branch prediction or resolution logic)
  wire [63:0] PCF;  // Current PC value 
  wire [63:0] PC_4F;  // PC + 4 (always points to the next sequential instruction address)
  wire [31:0] instruction_F;  // Fetched instruction
  wire predict_taken;  // Predicted branch outcome
  wire [63:0] target_pc;  // Predicted branch target address

  // Branch Prediction Unit instantiation
  BranchPredictionUnit bpu (
      .clk                   (clk),
      .reset                 (reset),
      .pc                    (PCF),                     // Current PC
      .branch_resolved       (branch_resolved),         // Branch resolution signal
      .actual_taken          (actual_taken),            // Actual branch outcome
      .branch_pc             (branch_pc),               // PC of the resolved branch
      .branch_target_resolved(branch_target_resolved),  // Resolved branch target (should be PC_Target_E)
      .predict_taken         (predict_taken),           // Predicted branch outcome 
      .target_pc             (target_pc)                // Predicted branch target address
  );

  // Multiplexer to select between predicted or resolved PC
  mux PC_mux (
      .a((predict_taken) ? target_pc : PC_4F),  // Predicted next PC (if branch predicted taken)
      .b(PC_Target_E),                          // Resolved branch target address
      .s(PCSrc_E),                              // Resolved branch decision
      .c(PC_F)                                  // Selected PC
  );

  // Program Counter with PCWrite control
  PC pc (
      .clk    (clk),
      .reset  (reset),
      .PCWrite(PCWrite),  // Control signal to allow/stall PC updates
      .pc_in  (PC_F),     // Next PC value
      .pc_out (PCF)       // Current PC value
  );

  // Instruction Memory
  InstructionMemory instr_mem (
      .clk        (clk),
      .address    (PCF),           // Address from PC
      .instruction(instruction_F)  // Fetched instruction
  );

  // PC + 4 calculation
  assign PC_4F = PCF + 64'd4;

  // Outputs with reset logic
  assign instruction_D = (reset) ? 32'd0 : instruction_F;
  assign PC_D = (reset) ? 64'd0 : PCF;

endmodule
