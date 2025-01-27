module Exception_Detection_Unit (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] instruction,     // fomr ID
    input  wire [63:0] pc,              // from IF
    output reg         exception_flag,  // to control unit
    output reg  [31:0] scause,
    output reg  [63:0] sepc
);

  // Cause examples
  parameter ILLEGAL_INSTRUCTION = 32'd2;
  parameter MEMORY_VIOLATION = 32'd5;

  wire is_memory_violation;

  // check if the instruction is a load or store and the memory address is misaligned
  assign is_memory_violation = (instruction[6:0] == 7'b0000011 || instruction[6:0] == 7'b0100011) && (pc % 4 != 0);

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      exception_flag <= 0;
      scause <= 32'b0;
      sepc <= 64'b0;
    end else begin
      exception_flag <= 0;

      if (instruction[6:0] == 7'b1111111) begin  // Undefined opcode
        exception_flag <= 1;
        scause <= ILLEGAL_INSTRUCTION;
        sepc <= pc;
      end else if (is_memory_violation) begin  // Memory access violation
        exception_flag <= 1;
        scause <= MEMORY_VIOLATION;
        sepc <= pc;
      end
    end
  end
endmodule

