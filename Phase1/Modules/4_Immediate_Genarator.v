module ImmediateGenerator (
    input [31:0] instruction,  
    output reg [63:0] imm_out  
);

  always @(*) begin
    case (instruction[6:0])  // Decode opcode
      // I-Type
      // Example: addi, lb, jalr
      7'b0010011: imm_out = {{52{instruction[31]}}, instruction[31:20]};
      7'b0000011: imm_out = {{52{instruction[31]}}, instruction[31:20]};
      7'b1100111: imm_out = {{52{instruction[31]}}, instruction[31:20]};
      7'b0011011: imm_out = {{52{instruction[31]}}, instruction[31:20]};
      
      // S-Type
      // Example: sw, sh
      7'b0100011: imm_out = {{52{instruction[31]}}, instruction[31:25], instruction[11:7]};

      // SB-Type
      // Example: beq, bne
      7'b1100011: imm_out = {{51{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};

      // U-Type
      // LUI
      7'b0111000: imm_out = {{32{instruction[31]}},instruction[31:12], 12'b0};

      // UJ-Type
      // Example: jal
      7'b1101111: imm_out = {
			{43{instruction[31]}},
			instruction[31],
			instruction[19:12],
			instruction[20],
			instruction[30:21], 1'b0
		      };

      // Default case for unsupported opcodes
      default: imm_out = 64'b0;
    endcase
  end
endmodule
