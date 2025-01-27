module InstructionMemory (
    input             clk,
    input      [63:0] address,     // Input: Address from PC
    output reg [31:0] instruction  // Output: Fetched instruction
);
  reg [7:0] mem[0:65535];  // 64 KB x 1 byte

  initial begin
    // addiw x1, x0, 4
    mem[0]  = 8'H13;  // LSB
    mem[1]  = 8'H00;
    mem[2]  = 8'H40;
    mem[3]  = 8'H00;  // MSB

    // addw x2, x1, x1
    mem[4]  = 8'H1B;
    mem[5]  = 8'H81;
    mem[6]  = 8'H20;
    mem[7]  = 8'H00;

    // sub x3, x2, x1
    mem[8]  = 8'H33;
    mem[9]  = 8'H10;
    mem[10] = 8'H11;
    mem[11] = 8'H40;

    // beq x1, x2, label
    mem[12] = 8'H63;
    mem[13] = 8'H86;
    mem[14] = 8'H20;
    mem[15] = 8'H00;

    // jal x0, 16
    mem[16] = 8'H6F;
    mem[17] = 8'H00;
    mem[18] = 8'H00;
    mem[19] = 8'H00;
  end

  // Fetch instruction using word addressing
  always @(posedge clk) begin
    instruction[7:0]   = mem[address];
    instruction[15:8]  = mem[address+1];
    instruction[23:16] = mem[address+2];
    instruction[31:24] = mem[address+3];
  end

endmodule
