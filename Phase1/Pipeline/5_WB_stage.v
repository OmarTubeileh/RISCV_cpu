module WB_Stage(
    input wire clk,
    input wire RegWriteW,          // Write enable signal
    input wire MemToRegW,          // Source select signal
    input wire [63:0] ALU_ResultW, // Result from ALU
    input wire [63:0] ReadDataW,   // Data read from memory
    input wire [4:0] RD_W,         // Destination register address
    output reg [63:0] WriteData    // Data to write back
);

    always @(*) begin
        if (RegWriteW) begin
            // Select between ALU_ResultW and ReadDataW
            WriteData = (MemToRegW) ? ReadDataW : ALU_ResultW;
        end else begin
            WriteData = 64'b0; // Default when write is disabled
        end
    end

endmodule
