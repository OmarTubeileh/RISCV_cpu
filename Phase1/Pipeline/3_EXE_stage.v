`include "6_ALU.v"
`include "adder.v"

module EXE_Stage(
    input clk,
    input reset,
    input RegWriteE,
    input ALUSrcE,
    input MemWriteE, MemToRegE, MemReadE,
    input [2:0] ALUOpE,            // ALU Control Signal from Control Unit
    input [63:0] RD1_E,            // First operand from Register File
    input [63:0] RD2_E,            // Second operand from Register File
    input [63:0] Imm_E,            // Immediate value
    input [4:0] RD_E,              // Destination register
    input [63:0] PCE,              // Program Counter
    input BEQ_E,                   // Branch equal signal
    input BNE_E,                   // Branch not equal signal
    input JAL_E,                   // Jump and link signal
    input JALR_E,                  // Jump and link register signal
    output reg PCSrcE,             // Branch decision
    output reg RegWriteM,
    output reg MemWriteM, MemToRegM, MemReadM,
    output reg [4:0] RD_M,
    output reg [63:0] WriteDataM,
    output reg [63:0] ALU_ResultM,
    output reg [63:0] PCTargetE    // Branch target address
);

    // Internal signals
    reg [63:0] SrcA, SrcB;         // ALU operands
    wire [63:0] ALUResult;         // ALU output
    wire ZeroFlag;                 // ALU zero flag
    wire [63:0] BranchTarget;      // Branch target address

    // Select between RD2 and Immediate for ALU_B input
    always @(*) begin
        SrcA = RD1_E;  // Operand A is always RD1_E
        SrcB = (ALUSrcE) ? Imm_E : RD2_E;  // Operand B based on ALUSrcE
    end

    // ALU Instance
    ALU alu_unit (
        .input1(SrcA),
        .input2(SrcB),
        .alu_control({1'b0, ALUOpE}),  // ALUOpE is extended to match ALU's 4-bit control
        .result(ALUResult),
        .zero(ZeroFlag)
    );

    // Branch Target Calculation
    Adder branch_adder (
        .A(PCE),
        .B(Imm_E),
        .Cin(1'b0),
        .Sum(BranchTarget),
        .Cout()  // Carry-out is unused
    );

    // Update Pipeline Registers and Compute Branch Decision
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all pipeline outputs
            PCSrcE <= 0;
            RegWriteM <= 0;
            MemWriteM <= 0;
            MemToRegM <= 0;
	    MemReadM <= 0; 
            RD_M <= 0;
            WriteDataM <= 0;
            ALU_ResultM <= 0;
            PCTargetE <= 0;
        end else begin
            // Branch decision
            PCSrcE <= (BEQ_E && ZeroFlag) || (BNE_E && !ZeroFlag) || JAL_E || JALR_E;

            // Pass signals to MEM stage
            RegWriteM <= RegWriteE;
            MemWriteM <= MemWriteE;
            MemToRegM <= MemToRegE;
	    MemReadM <= MemReadE;
            RD_M <= RD_E;
            WriteDataM <= RD2_E;  // Data for memory write
            ALU_ResultM <= ALUResult;
            PCTargetE <= BranchTarget;  // Calculated branch target
        end
    end

endmodule
