module ControlUnit (
    input [6:0] opcode,  // Opcode field from the instruction
    input [2:0] funct3,  // FUNCT3 field from the instruction
    input exception_flag,  // Exception detection flag
    output reg MemReadEn,  // Memory read enable (Enables memory read operation in the pipeline)
    output reg MemToReg,  // Memory to register selection
    output reg MemWriteEn,  // Memory write enable
    output reg [1:0] MemType,  // Type of memory operation (0:byte, 1:half word, 2:word)
    output reg ALUSrc,  // ALU source selection
    output reg RegWrite,  // Register write enable
    output reg BEQ,  // Branch equal enable
    output reg BNE,  // Branch not equal enable
    output reg JALen,  // Jump and link enable
    output reg JALRen,  // Jump and link register enable
    output reg       Mem_Read,   // Memory read signal (Triggers the actual memory read operation in the MEM stage)
    output reg [3:0] ALUop,  // ALU operation signal
    output reg flush_pipeline,  // Signal to flush the pipeline
    output reg jump_to_handler  // Signal to jump to exception handler
);

  always @(*) begin
    // Default values
    MemReadEn       = 0;
    MemToReg        = 0;
    MemWriteEn      = 0;
    MemType         = 2'b0;
    ALUSrc          = 0;
    RegWrite        = 0;
    BEQ             = 0;
    BNE             = 0;
    JALen           = 0;
    JALRen          = 0;
    Mem_Read        = 0;
    ALUop           = 4'b1111;  // Default no operation
    flush_pipeline  = 0;
    jump_to_handler = 0;

    // Handle exception
    if (exception_flag) begin
      flush_pipeline  = 1;  // Flush the pipeline
      jump_to_handler = 1;  // Jump to exception handler
    end else begin
      // Handle each instruction based on opcode and funct3
      if (opcode == 7'h33 && funct3 == 3'h1) begin
        // ADD
        ALUop = 4'b0010;
        RegWrite = 1;
      end else if (opcode == 7'h13 && funct3 == 3'h0) begin
        // ADDI
        ALUop = 4'b0010;
        ALUSrc = 1;
        RegWrite = 1;
      end else if (opcode == 7'h33 && funct3 == 3'h7) begin
        // AND
        ALUop = 4'b0000;
        RegWrite = 1;
      end else if (opcode == 7'h1B && funct3 == 3'h6) begin
        // ANDI
        ALUop = 4'b0000;
        ALUSrc = 1;
        RegWrite = 1;
      end else if (opcode == 7'h63 && funct3 == 3'h0) begin
        // BEQ
        ALUop = 4'b0110;
        BEQ   = 1;
      end else if (opcode == 7'h63 && funct3 == 3'h1) begin
        // BNE
        ALUop = 4'b0110;
        BNE   = 1;
      end else if (opcode == 7'h6F) begin
        // JAL
        JALen = 1;
        MemToReg = 1;
        RegWrite = 1;
      end else if (opcode == 7'h67) begin
        // JALR
        JALRen   = 1;
        MemToReg = 1;
        RegWrite = 1;
        ALUSrc   = 1;
      end else if (opcode == 7'h03 && funct3 == 3'h2) begin
        // LH
        MemReadEn = 1;
        MemToReg = 1;
        RegWrite = 1;
        ALUSrc = 1;
        Mem_Read = 1;
        MemType = 1;
        ALUop = 4'b0010;
      end else if (opcode == 7'h38) begin
        // LUI
        ALUop = 4'b1001;
        RegWrite = 1;
      end else if (opcode == 7'h03 && funct3 == 3'h0) begin
        // LW
        MemReadEn = 1;
        MemToReg = 1;
        RegWrite = 1;
        ALUSrc = 1;
        Mem_Read = 1;
        MemType = 2;
        ALUop = 4'b0010;
      end else if (opcode == 7'h33 && funct3 == 3'h3) begin
        // XOR
        ALUop = 4'b0011;
        RegWrite = 1;
      end else if (opcode == 7'h33 && funct3 == 3'h5) begin
        // OR
        ALUop = 4'b0001;
        RegWrite = 1;
      end else if (opcode == 7'h13 && funct3 == 3'h7) begin
        // ORI
        ALUop = 4'b0001;
        ALUSrc = 1;
        RegWrite = 1;
      end else if (opcode == 7'h33 && funct3 == 3'h0) begin
        // SLT
        ALUop = 4'b0111;
        RegWrite = 1;
      end else if (opcode == 7'h33 && funct3 == 3'h4) begin
        // SLL
        ALUop = 4'b0100;
        RegWrite = 1;
      end else if (opcode == 7'h33 && funct3 == 3'h2) begin
        // SRL
        ALUop = 4'b0101;
        RegWrite = 1;
      end else if (opcode == 7'h23 && funct3 == 3'h0) begin
        // SB
        MemWriteEn = 1;
        ALUSrc = 1;
        MemType = 0;
        ALUop = 4'b0010;
      end else if (opcode == 7'h23 && funct3 == 3'h2) begin
        // SW
        MemWriteEn = 1;
        ALUSrc = 1;
        MemType = 2;
        ALUop = 4'b0010;
      end else if (opcode == 7'h33 && funct3 == 3'h6) begin
        // SUB
        ALUop = 4'b0110;
        RegWrite = 1;
      end
    end
  end
endmodule
