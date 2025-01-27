module ALU (
    input      [63:0] input1,       // First operand
    input      [63:0] input2,       // Second operand
    input      [ 3:0] alu_control,  // ALU control signal
    output reg [63:0] result,       // Result of the ALU operation
    output            zero          // Zero flag: High if result is 0
);

  // Perform the operation based on alu_control
  always @(*) begin
    case (alu_control)
      4'b0000: result = input1 & input2;  // AND
      4'b0001: result = input1 | input2;  // OR
      4'b0011: result = input1 ^ input2;  // XOR

      4'b0010: result = input1 + input2;  // Addition
      4'b0110: result = input1 - input2;  // Subtraction

      4'b0100: result = input1 << input2[5:0];  // Shift Left Logical (SLL)
      4'b0101: result = input1 >> input2[5:0];  // Shift Right Logical (SRL)

      4'b0111: result = ($signed(input1) < $signed(input2)) ? 1 : 0;  // Set Less Than (signed)
      4'b1000: result = (input1 < input2) ? 1 : 0;  // Set Less Than (Unsigned) 

      //4'b1101: result = $signed(input1) >>> input2[5:0]; // Shift Right Arithmetic (SRA)
      //4'b1100: result = $signed(input1) <<< input2[5:0]; // Shift Left Arithmetic (SLA)

      4'b1001: result = input2 << 12;  // LUI operation

      default: result = 64'b0;  // Default to 0 for unrecognized control signals
    endcase
  end

  // Zero flag: Set to 1 if result is 0, otherwise 0
  assign zero = (result == 0);

endmodule

// [5:0] to limit shifts
// Logical shift: empty bits are filled with zeros
// Arithmetic shift: empty bits are filled with the MSB of input1, preserving the sign for signed numbers
