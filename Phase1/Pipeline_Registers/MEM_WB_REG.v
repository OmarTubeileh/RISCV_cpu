module MEM_WB_REG(
    input clk,
    input reset,
    input RegWriteM,
    input MemToRegM,
    input [63:0] ReadDataM,
    input [63:0] ALU_ResultM,
    input [4:0] RD_M,
    output reg RegWriteW,
    output reg MemToRegW,
    output reg [63:0] ReadDataW,
    output reg [63:0] ALU_ResultW,
    output reg [4:0] RD_W
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            RegWriteW <= 0;
            MemToRegW <= 0;
            ReadDataW <= 64'b0;
            ALU_ResultW <= 64'b0;
            RD_W <= 5'b0;
        end else begin
            RegWriteW <= RegWriteM;
            MemToRegW <= MemToRegM;
            ReadDataW <= ReadDataM;
            ALU_ResultW <= ALU_ResultM;
            RD_W <= RD_M;
        end
    end

endmodule
