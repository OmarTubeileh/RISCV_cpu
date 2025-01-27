`include "3_Control_Unit.v"
`include "4_Immediate_Genarator.v"
`include "5_Register_File.v"

module ID_Stage(
    input wire clk,
    input wire reset,
    input wire [31:0] instruction_D,  // Instruction from IF/ID Register
    input wire [63:0] PC_D,           // PC from IF/ID Register
    input wire [63:0] write_data,     // Data to write into the register
    input wire [4:0] write_reg,       // Destination register for WB (comes from WB)
    input wire reg_write,             // Register write enable 
    output wire [63:0] data_rs1,      // Value from rs1
    output wire [63:0] data_rs2,      // Value from rs2
    output wire [63:0] imm_val,       // Immediate value
    output wire [4:0] rs1,            // Source register 1
    output wire [4:0] rs2,            // Source register 2
    output wire [4:0] rd,             // Destination register
    output wire [2:0] ALUop,          // ALU operation
    output wire MemReadEn,            // Memory read enable
    output wire MemToReg,             // Memory to register selection (determines if data is from memory(1) or ALU(0))
    output wire MemWriteEn,           // Memory write enable
    output wire ALUSrc,               // ALU source selection
    output wire RegWrite,             // Register write enable
    output wire BEQ,                  // Branch equal enable
    output wire BNE,                  // Branch not equal enable
    output wire JALen,                // Jump and link enable
    output wire JALRen                // Jump and link register enable
);

    // Extract fields from the instruction
    assign rs1 = instruction_D[19:15];
    assign rs2 = instruction_D[24:20];
    assign rd  = instruction_D[11:7];

    // Register File
    RegisterFile reg_file (
        .clk(clk),
        .reset(reset),
        .read_reg1(rs1),            // Read register 1 address
        .read_reg2(rs2),            // Read register 2 address
        .write_reg(write_reg),      // Write-back register address
        .reg_write(reg_write),      // Write enable
        .write_data(write_data),    // Write-back data
        .read_data1(data_rs1),      // Output: rs1 value
        .read_data2(data_rs2)       // Output: rs2 value
    );

    // Immediate Generator
    ImmediateGenerator imm_gen (
        .instruction(instruction_D),
        .imm_out(imm_val)
    );

    // Control Unit
    ControlUnit control_unit (
        .opcode(instruction_D[6:0]),
        .funct3(instruction_D[14:12]),
        .MemReadEn(MemReadEn),
        .MemToReg(MemToReg),
        .MemWriteEn(MemWriteEn),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .BEQ(BEQ),
        .BNE(BNE),
        .JALen(JALen),
        .JALRen(JALRen),
        .Mem_Read(),	//unecessary (keep empty)             
        .ALUop(ALUop)
    );

endmodule
