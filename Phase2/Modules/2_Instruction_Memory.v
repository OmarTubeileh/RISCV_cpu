module InstructionMemory (
    input             clk,
    input      [63:0] address,     // Input: Address from PC
    output reg [31:0] instruction  // Output: Fetched instruction
);
  reg [7:0] mem[0:65535];  // 64 KB x 1 byte
  // "64K" means 65,536 addresses

  initial begin
    // ===============
    //     Test case 1
    // ===============

    // addiw x1 x0 16     # x1 = 16
    mem[0]  = 8'H93;
    mem[1]  = 8'H00;
    mem[2]  = 8'H00;
    mem[3]  = 8'H01;

    // addiw x2 x0 8      # x2 = 8
    mem[4]  = 8'H93;
    mem[5]  = 8'H00;
    mem[6]  = 8'H10;
    mem[7]  = 8'H00;

    // addiw x4 x0 10    # x4 = 10
    mem[8]  = 8'H93;
    mem[9]  = 8'H00;
    mem[10] = 8'H28;
    mem[11] = 8'H00;

    // addiw x3 x0 0      # x3 = 0
    mem[12] = 8'H93;
    mem[13] = 8'H00;
    mem[14] = 8'H00;
    mem[15] = 8'H00;

    // addw x3 x1 x2     # x3 = x1 + x2
    mem[16] = 8'HB3;
    mem[17] = 8'H6C;
    mem[18] = 8'H41;
    mem[19] = 8'H50;

    // ===============
    //     Test case 2
    // ===============

    // addiw x1 x0 0xFF   # x1 = 0xFF
    mem[20] = 8'H93;
    mem[21] = 8'H0F;
    mem[22] = 8'HF0;
    mem[23] = 8'H00;

    // addiw x2 x0 0xF0  # x2 = 0xF0
    mem[24] = 8'H93;
    mem[25] = 8'H0E;
    mem[26] = 8'HF1;
    mem[27] = 8'H00;

    // addiw x4 x0 0        # x4 = 0
    mem[28] = 8'H93;
    mem[29] = 8'H00;
    mem[30] = 8'H22;
    mem[31] = 8'H01;

    // andi x4 x1 0x0F     # x4 = x2 & 0x0F
    mem[32] = 8'H93;
    mem[33] = 8'H03;
    mem[34] = 8'HFF;
    mem[35] = 8'H01;

    // xor x7 x1 x2           # x7 = x1 ^ x2
    mem[36] = 8'HB3;
    mem[37] = 8'H62;
    mem[38] = 8'HF1;
    mem[39] = 8'H01;

    // and x3 x1 x2          # x3 = x1 & x2
    mem[40] = 8'HB3;
    mem[41] = 8'HF0;
    mem[42] = 8'HA0;
    mem[43] = 8'H01;

    // ori x6 x2 0x0A       # x6 = x2 | 0x0A
    mem[44] = 8'H93;
    mem[45] = 8'H42;
    mem[46] = 8'H33;
    mem[47] = 8'H00;

    // or x5 x3 x4            # x5 = x3 | x4
    mem[48] = 8'H93;
    mem[49] = 8'HF2;
    mem[50] = 8'H32;
    mem[51] = 8'H01;


  end
  always @(posedge clk) begin
    instruction[7:0]   = mem[address];
    instruction[15:8]  = mem[address+1];
    instruction[23:16] = mem[address+2];
    instruction[31:24] = mem[address+3];
  end

endmodule
