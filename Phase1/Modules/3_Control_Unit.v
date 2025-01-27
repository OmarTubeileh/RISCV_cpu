module ControlUnit (
    input      [6:0] opcode,     // Opcode field from the instruction
    input      [2:0] funct3,     // FUNCT3 field from the instruction
    output reg       MemReadEn,  // Memory read enable (Enables memory read operation in the pipeline)
    output reg       MemToReg,   // Memory to register selection
    output reg       MemWriteEn, // Memory write enable
    output reg       ALUSrc,     // ALU source selection
    output reg       RegWrite,   // Register write enable
    output reg       BEQ,        // Branch equal enable
    output reg       BNE,        // Branch not equal enable
    output reg       JALen,      // Jump and link enable
    output reg       JALRen,     // Jump and link register enable
    output reg       Mem_Read,   // Memory read signal (Triggers the actual memory read operation in the MEM stage)
    output reg [2:0] ALUop       // ALU operation signal
);

    // Opcodes
    localparam R_TYPE  = 7'b0110011; // Register instructions (add, sub, etc.)
    localparam I_TYPE  = 7'b0010011; // Immediate instructions (addi, andi, ori, etc.)
    localparam LOAD    = 7'b0000011; // Load instructions (lw)
    localparam STORE   = 7'b0100011; // Store instructions (sw)
    localparam BRANCH  = 7'b1100011; // Branch instructions (beq, bne)
    localparam JAL     = 7'b1101111; // Jump and link
    localparam JALR    = 7'b1100111; // Jump and link register
    localparam LUI     = 7'b0110111; // Load upper immediate

    always @(*) begin
        // Default values
        MemReadEn  = 0;
        MemToReg   = 0;
        MemWriteEn = 0;
        ALUSrc     = 0;
        RegWrite   = 0;
        BEQ        = 0;
        BNE        = 0;
        JALen      = 0;
        JALRen     = 0;
        Mem_Read   = 0;
        ALUop      = 3'b000; // Default no operation

        case (opcode)
            R_TYPE: begin
                RegWrite = 1;
                ALUop = 3'b010; // Indicate R-type operation for ALU Control
            end
            I_TYPE: begin
                RegWrite = 1;
                ALUSrc = 1; // Use immediate
                ALUop = 3'b100; // Indicate I-type operation for ALU Control
            end
            LOAD: begin
                MemReadEn = 1;
                MemToReg = 1;
                RegWrite = 1;
                ALUSrc = 1; // Use immediate for address
                Mem_Read = 1;
                ALUop = 3'b000; // ADD for address calculation
            end
            STORE: begin
                MemWriteEn = 1;
                ALUSrc = 1; // Use immediate for address
                ALUop = 3'b000; // ADD for address calculation
            end
            BRANCH: begin
                ALUop = 3'b001; // Comparison operation for branches
                case (funct3)
                    3'b000: BEQ = 1; // BEQ
                    3'b001: BNE = 1; // BNE
                endcase
            end
            JALen: begin
                JALen = 1;
                MemToReg = 1; // Write PC+4 to rd
                RegWrite = 1;
                ALUop = 3'b011; // JAL operation
            end
            JALRen: begin
                JALRen = 1;
                MemToReg = 1; // Write PC+4 to rd
                RegWrite = 1;
                ALUSrc = 1; // Use immediate for target
                ALUop = 3'b011; // JALR operation
            end
            LUI: begin
                RegWrite = 1;
                ALUop = 3'b101; // LUI operation (handled in ALU)
            end
            default: begin
                // Default case with all signals set to zero
            end
        endcase
    end
endmodule
