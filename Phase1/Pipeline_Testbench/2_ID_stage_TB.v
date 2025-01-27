module tb_ID_Stage;

    // Signals
    reg clk;
    reg reset;
    reg [31:0] instruction_D;  // Instruction from IF/ID Register
    reg [63:0] PC_D;           // Program Counter from IF/ID Register
    reg [63:0] write_data;     // Data to write into the register file
    reg [4:0] write_reg;       // Destination register for WB
    reg reg_write;             // Register write enable signal
    wire [63:0] data_rs1;      // Data read from source register 1
    wire [63:0] data_rs2;      // Data read from source register 2
    wire [63:0] imm_val;       // Immediate value
    wire [4:0] rs1;            // Source register 1
    wire [4:0] rs2;            // Source register 2
    wire [4:0] rd;             // Destination register
    wire [2:0] ALUop;          // ALU operation
    wire MemReadEn;            // Memory read enable
    wire MemToReg;             // Memory to register selection
    wire MemWriteEn;           // Memory write enable
    wire ALUSrc;               // ALU source selection
    wire RegWrite;             // Register write enable
    wire BEQ;                  // Branch equal enable
    wire BNE;                  // Branch not equal enable
    wire JALen;                // Jump and link enable
    wire JALRen;               // Jump and link register enable

    // Instantiate the ID Stage module
    ID_Stage uut (
        .clk(clk),
        .reset(reset),
        .instruction_D(instruction_D),
        .PC_D(PC_D),
        .write_data(write_data),
        .write_reg(write_reg),
        .reg_write(reg_write),
        .data_rs1(data_rs1),
        .data_rs2(data_rs2),
        .imm_val(imm_val),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .ALUop(ALUop),
        .MemReadEn(MemReadEn),
        .MemToReg(MemToReg),
        .MemWriteEn(MemWriteEn),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .BEQ(BEQ),
        .BNE(BNE),
        .JALen(JALen),
        .JALRen(JALRen)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period: 10 ns
    end

    // Test sequence
    initial begin
        $dumpfile("ID_Stage_waveform.vcd");
        $dumpvars(0, tb_ID_Stage);

        // Initialize signals
        reset = 1;
        instruction_D = 32'd0;
        PC_D = 64'd0;
        write_data = 64'd0;
        write_reg = 5'd0;
        reg_write = 0;

        #10 reset = 0; // Deassert reset
      
        // Initialize register file
        uut.reg_file.registers[6] = 64'h0000000000000006; // x6
        uut.reg_file.registers[7] = 64'h0000000000000007; // x7
        uut.reg_file.registers[15] = 64'h000000000000000F; // x15
        uut.reg_file.registers[8] = 64'h0000000000000008; // x8
        uut.reg_file.registers[19] = 64'h0000000000000013; // x19
        uut.reg_file.registers[3] = 64'h0000000000000003; // x3



        // Test cases
        instruction_D = 32'b00000000011100110000000110110011; // R-Type: add x5, x6, x7
        #20;
        instruction_D = 32'b0000000000001111001100000010011; // I-Type: addi x5, x6, 15
        #20;
        instruction_D = 32'b0000000000001000001100100000011; // Load: lw x5, 8(x6)
        #20;
        instruction_D = 32'b0000000001010011001000001010011; // Store: sw x5, 8(x6)
        #20;
        instruction_D = 32'b0000000001110011000000001100011; // Branch: beq x6, x7, offset=8
        #20;
        instruction_D = 32'b0000000000010000000000000110111; // Jump: jal x1, offset=16
        #20;

        // Write to Register File
        write_data = 64'hDEADBEEF;
        write_reg = 5'b00101; // x5
        reg_write = 1;
        #20;
        reg_write = 0;

        // Reset During Operation
        reset = 1;
        #10 reset = 0;

        $finish;
    end

    // Monitor outputs
    initial begin
      $monitor("Time: %0t | Instruction: %b | PC: %h | rs1: %d | rs2: %d | rd: %d | data_rs1: %h | data_rs2: %h | imm_val: %h | ALUop: %b | MemReadEn: %b | MemToReg: %b | MemWriteEn: %b | ALUSrc: %b | RegWrite: %b | BEQ: %b | BNE: %b | JALen: %b | JALRen: %b",
                 $time, instruction_D, PC_D, rs1, rs2, rd, data_rs1, data_rs2, imm_val, ALUop, MemReadEn, MemToReg, MemWriteEn, ALUSrc, RegWrite, BEQ, BNE, JALen, JALRen);
    end

endmodule
