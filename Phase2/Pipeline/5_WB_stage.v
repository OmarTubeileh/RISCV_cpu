module WB_Stage(
    input wire clk,
    input wire RegWriteW,          // Write enable signal
    input wire MemToRegW,          // Source select signal
    input wire [63:0] ALU_ResultW, // Result from ALU
    input wire [63:0] ReadDataW,   // Data read from memory
    input wire [4:0] RD_W,         // Destination register address
    output reg [63:0] WriteData,   // Data to write back
    output reg [4:0] WriteReg      // Destination register address
);

    always @(posedge clk) begin
        if (RegWriteW) begin
            WriteData <= (MemToRegW) ? ReadDataW : ALU_ResultW;
            WriteReg <= RD_W;
        end else begin
            WriteData <= 64'b0;
            WriteReg <= 5'b0;
        end
    end

endmodule
