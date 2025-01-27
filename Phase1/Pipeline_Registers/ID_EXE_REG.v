module ID_EXE_REG (
    input clk,                   
    input reset,                 

    // Inputs from ID stage
    input RegWriteD, ALUSrcD, MemWriteD, MemReadD, MemTypeD, ResultSrcD,
    input [2:0] ALUOpD,          // ALU operation signal
    input [63:0] RD1_D,          // Read data 1 from Register File
    input [63:0] RD2_D,          // Read data 2 from Register File
    input [63:0] Imm_D,          // Immediate value
    input [4:0] RD_D,            // Destination register
    input [63:0] PCD,            // Program Counter value
    input BEQ_D, BNE_D, JAL_D, JALR_D, // Branch and jump control signals

    // Outputs to EXE stage
    output reg RegWriteE, ALUSrcE, MemWriteE, MemReadE, MemTypeE, ResultSrcE,
    output reg [2:0] ALUOpE,
    output reg [63:0] RD1_E,
    output reg [63:0] RD2_E,
    output reg [63:0] Imm_E,
    output reg [4:0] RD_E,
    output reg [63:0] PCE,
    output reg BEQ_E, BNE_E, JAL_E, JALR_E
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all pipeline register outputs
            RegWriteE <= 0;
            ALUSrcE <= 0;
            MemWriteE <= 0;
            MemReadE <= 0;
            MemTypeE <= 0;
            ResultSrcE <= 0;
            ALUOpE <= 3'b000;
            RD1_E <= 64'b0;
            RD2_E <= 64'b0;
            Imm_E <= 64'b0;
            RD_E <= 5'b0;
            PCE <= 64'b0;
            BEQ_E <= 0;
            BNE_E <= 0;
            JAL_E <= 0;
            JALR_E <= 0;
        end else begin
            // Pass signals and data from ID stage to EXE stage
            RegWriteE <= RegWriteD;
            ALUSrcE <= ALUSrcD;
            MemWriteE <= MemWriteD;
            MemReadE <= MemReadD;
            MemTypeE <= MemTypeD;
            ResultSrcE <= ResultSrcD;
            ALUOpE <= ALUOpD;
            RD1_E <= RD1_D;
            RD2_E <= RD2_D;
            Imm_E <= Imm_D;
            RD_E <= RD_D;
            PCE <= PCD;
            BEQ_E <= BEQ_D;
            BNE_E <= BNE_D;
            JAL_E <= JAL_D;
            JALR_E <= JALR_D;
        end
    end

endmodule
