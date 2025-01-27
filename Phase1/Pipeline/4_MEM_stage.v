`include "7_Data_Memory.v"

module MEM_Stage (
    input clk,                     // Clock signal
    input reset,                   // Reset signal (active-high)
    
    // Inputs from EXE/MEM Register
    input RegWriteM,               // Register write enable
    input MemWriteM,               // Memory write enable
    input MemReadM,                // Memory read enable
    input MemtoRegM,               // Memory to register signal
    input [63:0] ALU_ResultM,      // Address for memory access / ALU result
    input [63:0] WriteDataM,       // Data to write to memory
    input [4:0] RD_M,              // Destination register for WB stage

    // Outputs to MEM/WB Register
    output reg RegWriteW,          // Forwarded to WB stage
    output reg MemtoRegW,          // Forwarded to WB stage
    output reg [63:0] ReadDataW,   // Data read from memory (if MemReadM)
    output reg [63:0] ALU_ResultW, // Forwarded ALU result to WB stage
    output reg [4:0] RD_W          // Forwarded destination register to WB stage
);

    // Instantiate Data Memory
    wire [63:0] ReadData;          // Data read from memory

    DataMemory data_memory (
        .clk(clk),
        .mem_read(MemReadM),
        .mem_write(MemWriteM),
        .address(ALU_ResultM),
        .write_data(WriteDataM),
        .read_data(ReadData)
    );

    // Pass signals to MEM/WB Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset outputs
            RegWriteW <= 0;
            MemtoRegW <= 0;
            ReadDataW <= 0;
            ALU_ResultW <= 0;
            RD_W <= 0;
        end else begin
            // Update outputs
            RegWriteW <= RegWriteM;
            MemtoRegW <= MemtoRegM;
            ReadDataW <= ReadData;  // Data read from memory
            ALU_ResultW <= ALU_ResultM; // Forward ALU result
            RD_W <= RD_M;          // Forward destination register
        end
    end

endmodule
