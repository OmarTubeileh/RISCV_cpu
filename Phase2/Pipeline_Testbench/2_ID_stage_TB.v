module tb_ID_Stage;

  // Signals
  reg clk;
  reg reset;
  reg [31:0] instruction_D;
  reg [63:0] PC_D;
  reg [63:0] write_data;
  reg [4:0] write_reg;
  reg reg_write;
  wire [63:0] data_rs1;
  wire [63:0] data_rs2;
  wire [63:0] imm_val;
  wire [4:0] rs1, rs2, rd;
  wire [3:0] ALUop;
  wire MemReadEn, MemToReg, MemWriteEn, ALUSrc, RegWrite;
  wire BEQ, BNE, JALen, JALRen;

  // Instantiate the module
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
    forever #5 clk = ~clk;
  end

  // Test sequence
  initial begin
    $dumpfile("ID_Stage_waveform.vcd");
    $dumpvars(0, tb_ID_Stage);

    reset = 1;
    instruction_D = 32'd0;
    PC_D = 64'd0;
    write_data = 64'd0;
    write_reg = 5'd0;
    reg_write = 0;

    #10 reset = 0;

    // Test R-Type instruction addw x3 x1 x2     # x3 = x1 + x2
    instruction_D = 32'b00101000001000001001000110110011;
    #20;

    // Test I-Type instruction addiw x1 x0 16     # x1 = 16
    instruction_D = 32'b00000001000000000000000010010011;
    #20;

    // Test S-Type instruction sw x1 0(x3)            # MEM[32] = x1	x6 = 0
    instruction_D = 32'b0000000_00001_00011_010_00000_0100011;
    #20;

    // Test B-Type instruction beq x3 x0 ge           # If x1 >= x2, jump to "ge"	x4 = 0
    instruction_D = 32'b00000010000000011000000001100011;
    #20;

    // Test U-Type instruction (lui x5, imm)
    instruction_D = 32'b00000000000000000001000010110111;
    #20;

    // Test J-Type instruction (jal x1, offset)
    instruction_D = 32'b00000000000100000000000001101111;
    #20;

    // Test Register Write
    write_data = 64'h123456789ABCDEF0;
    write_reg  = 5'b00101;
    reg_write  = 1;
    #20 reg_write = 0;

    $finish;
  end

  // Monitor
  initial begin
    $monitor(
        "Time: %0t | Instruction: %b | rs1: %d | rs2: %d | rd: %d | imm_val: %b | ALUop: %b | MemReadEn: %b | MemWriteEn: %b | RegWrite: %b | BEQ: %b",
        $time, instruction_D, rs1, rs2, rd, imm_val, ALUop, MemReadEn, MemWriteEn, RegWrite, BEQ);
  end

endmodule
