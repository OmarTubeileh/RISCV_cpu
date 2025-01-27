module tb_ControlUnit;

    reg [6:0] opcode;             
    reg [2:0] funct3;             
    wire       MemReadEn;         
    wire       MemToReg;          
    wire       MemWriteEn;        
    wire       ALUSrc;            
    wire       RegWrite;          
    wire       BEQ;               
    wire       BNE;               
    wire       JALen;             
    wire       JALRen;            
    wire       Mem_Read;          
    wire [2:0] ALUop;             

    ControlUnit uut (
        .opcode(opcode),
        .funct3(funct3),
        .MemReadEn(MemReadEn),
        .MemToReg(MemToReg),
        .MemWriteEn(MemWriteEn),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .BEQ(BEQ),
        .BNE(BNE),
      	.JALen(JALen),
      	.JALRen(JALRen),
        .Mem_Read(Mem_Read),
        .ALUop(ALUop)
    );

    initial begin
        $dumpfile("waveform.vcd");  
        $dumpvars(0, tb_ControlUnit);

        // Test case 1: R-Type instruction (ADD)
        opcode = 7'b0110011;  // R_TYPE
        funct3 = 3'b000;      // ADD
        #10;

        // Test case 2: I-Type instruction (ADDI)
        opcode = 7'b0010011;  // I_TYPE
        funct3 = 3'b000;      // ADDI
        #10;

        // Test case 3: Load instruction (LW)
        opcode = 7'b0000011;  // LOAD
        funct3 = 3'b010;      // LW
        #10;

        // Test case 4: Store instruction (SW)
        opcode = 7'b0100011;  // STORE
        funct3 = 3'b010;      // SW
        #10;

        // Test case 5: Branch instruction (BEQ)
        opcode = 7'b1100011;  // BRANCH
        funct3 = 3'b000;      // BEQ
        #10;

        // Test case 6: Jump and Link instruction (JAL)
        opcode = 7'b1101111;  // JAL
        funct3 = 3'b000;      // (funct3 not used for JAL)
        #10;

        // Test case 7: Jump and Link Register (JALR)
        opcode = 7'b1100111;  // JALR
        funct3 = 3'b000;      // (funct3 not used for JALR)
        #10;

        // Test case 8: LUI instruction
        opcode = 7'b0110111;  // LUI
        funct3 = 3'b000;      // (funct3 not used for LUI)
        #10;

        // Test case 9: Store Byte (SB)
        opcode = 7'b0100011;  // STORE
        funct3 = 3'b000;      // SB
        #10;

        $finish; 
    end

    initial begin
      $monitor("Time: %0t | Opcode: %b | FUNCT3: %b | ALUop: %b | MemReadEn: %b | MemToReg: %b | MemWriteEn: %b | ALUSrc: %b | RegWrite: %b | BEQ: %b | BNE: %b | JAL: %b | JALR: %b | Mem_Read: %b",
                 $time, opcode, funct3, ALUop, MemReadEn, MemToReg, MemWriteEn, ALUSrc, RegWrite, BEQ, BNE, JALen, JALRen, Mem_Read);
    end

endmodule
