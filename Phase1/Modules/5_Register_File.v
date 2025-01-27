module RegisterFile (
    input         clk,          // Input: Clock signal
    input         reset,        // Input: Active-high reset signal
    input  [4:0]  read_reg1,    // Input: Address of the first register to read
    input  [4:0]  read_reg2,    // Input: Address of the second register to read
    input  [4:0]  write_reg,    // Input: Address of the register to write
    input         reg_write,    // Input: Write enable signal
    input  [63:0] write_data,   // Input: Data to write to the register
    output [63:0] read_data1,   // Output: Data read from the first register
    output [63:0] read_data2    // Output: Data read from the second register
);

    // Internal 64-bit registers (32 registers in total)
    reg [63:0] registers[0:31];
    integer i;

    // Initialize all registers to 0
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 64'd0;
    end

    // Write logic: Update the register file on the positive clock edge
    always @(posedge clk) begin
        if (reset) begin
            // Reset all registers to 0
            for (i = 0; i < 32; i = i + 1) registers[i] <= 64'd0;
        end 
	else if (reg_write && write_reg != 5'd0) begin
        // Write to the register only if reg_write is enabled and not x0 (zero register)
            registers[write_reg] <= write_data;
        end
    end

    // Read logic: Asynchronous reads
    assign read_data1 = (read_reg1 == 5'd0) ? 64'd0 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 5'd0) ? 64'd0 : registers[read_reg2];

endmodule
