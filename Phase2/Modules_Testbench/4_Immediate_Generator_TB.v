module tb_ImmediateGenerator;

  // Signals
  reg  [31:0] instruction;
  wire [63:0] imm_out;

  ImmediateGenerator uut (
      .instruction(instruction),
      .imm_out(imm_out)
  );

  // Test sequence
  initial begin
    $dumpfile("ImmediateGenerator_waveform.vcd");
    $dumpvars(0, tb_ImmediateGenerator);

    // Test case 1: I-Type instruction (addi)
    instruction = 32'b000000000001_00001_000_00010_0010011;  // addi x2, x1, 1
    #10;

    // Test case 2: S-Type instruction (sw)
    instruction = 32'b0000000_00010_00001_010_00011_0100011;  // sw x2, 3(x1)
    #10;

    // Test case 3: SB-Type instruction (beq)
    instruction = 32'b0000000_00001_00010_000_11111_1100011;  // beq x1, x2, -16
    #10;

    // Test case 4: U-Type instruction (lui)
    instruction = 32'b00000000000000000001_00001_0110111;  // lui x1, 0x10000
    #10;

    // Test case 5: UJ-Type instruction (jal)
    instruction = 32'b00000000000000000010_00001_1101111;  // jal x1, 0x2
    #10;

    // Test case 6: Default case
    instruction = 32'b11111111111111111111111111111111;  // Unrecognized opcode
    #10;

    $finish;
  end

  initial begin
    $monitor("Time: %t | Instruction: %b | Immediate Output: %b", $time, instruction, imm_out);
  end

endmodule
