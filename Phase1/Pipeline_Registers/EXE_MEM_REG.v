module EXE_MEM_REG (
    input clk,
    input reset,
    // Control Signals
    input RegWriteE,
    input MemWriteE,
    input MemToRegE,
    input MemReadE,
    input [1:0] MemTypeE,         
    input [63:0] ALUResultE,
    input [63:0] WriteDataE,      // Data to be written to memory
    input [4:0] RD_E,             // Destination register address
    input PCSrcE,                 // Branch decision
    input [63:0] PCTargetE,       // Branch target address

    // Outputs to MEM Stage
    output reg RegWriteM,
    output reg MemWriteM,
    output reg MemToRegM,
    output reg MemReadM,
    output reg [1:0] MemTypeM,
    output reg [63:0] ALUResultM,
    output reg [63:0] WriteDataM,
    output reg [4:0] RD_M,
    output reg PCSrcM,
    output reg [63:0] PCTargetM
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all outputs to default values
            RegWriteM <= 0;
            MemWriteM <= 0;
            MemToRegM <= 0;
            MemTypeM <= 2'b0;
	    MemReadM <= 0;
            ALUResultM <= 64'b0;
            WriteDataM <= 64'b0;
            RD_M <= 5'b0;
            PCSrcM <= 0;
            PCTargetM <= 64'b0;
        end else begin
            // Pass signals from EXE to MEM stage
            RegWriteM <= RegWriteE;
            MemWriteM <= MemWriteE;
            MemToRegM <= MemToRegE;
	    MemReadM <= MemReadE;
            MemTypeM <= MemTypeE;
            ALUResultM <= ALUResultE;
            WriteDataM <= WriteDataE;
            RD_M <= RD_E;
            PCSrcM <= PCSrcE;
            PCTargetM <= PCTargetE;
        end
    end

endmodule
