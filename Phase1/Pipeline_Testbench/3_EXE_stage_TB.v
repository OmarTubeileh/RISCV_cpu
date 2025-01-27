module tb_EXE_Stage;

    // Inputs
    reg clk;
    reg reset;
    reg RegWriteE, ALUSrcE, MemWriteE, MemReadE, ResultSrcE;
    reg [2:0] ALUOpE;
    reg [63:0] RD1_E, RD2_E, Imm_Ext_E, PCE;
    reg [4:0] RD_E;
    reg BEQ_E, BNE_E, JAL_E, JALR_E;

    // Outputs
    wire PCSrcE;
    wire RegWriteM, MemWriteM, MemReadM, ResultSrcM;
    wire [4:0] RD_M;
    wire [63:0] WriteDataM, ALU_ResultM, PCTargetE;

    // Instantiate the EXE Stage
    EXE_Stage uut (
        .clk(clk),
        .reset(reset),
        .RegWriteE(RegWriteE),
        .ALUSrcE(ALUSrcE),
        .MemWriteE(MemWriteE),
        .MemReadE(MemReadE),         // New input
        .MemToRegE(ResultSrcE),
        .ALUOpE(ALUOpE),
        .RD1_E(RD1_E),
        .RD2_E(RD2_E),
        .Imm_E(Imm_Ext_E),
        .PCE(PCE),
        .RD_E(RD_E),
        .BEQ_E(BEQ_E),
        .BNE_E(BNE_E),
        .JAL_E(JAL_E),
        .JALR_E(JALR_E),
        .PCSrcE(PCSrcE),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .MemReadM(MemReadM),        // New output
        .MemToRegM(ResultSrcM),
        .RD_M(RD_M),
        .WriteDataM(WriteDataM),
        .ALU_ResultM(ALU_ResultM),
        .PCTargetE(PCTargetE)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        $dumpfile("exe_stage_test.vcd");
        $dumpvars(0, tb_EXE_Stage);

        // Initialize inputs
        clk = 0;
        reset = 1;
        RegWriteE = 0;
        ALUSrcE = 0;
        MemWriteE = 0;
        MemReadE = 0;               // Initialize new signal
        ResultSrcE = 0;
        ALUOpE = 3'b000;
        RD1_E = 0;
        RD2_E = 0;
        Imm_Ext_E = 0;
        PCE = 0;
        RD_E = 0;
        BEQ_E = 0;
        BNE_E = 0;
        JAL_E = 0;
        JALR_E = 0;

        // Reset cycle
        #10 reset = 0;

        // Test 1: Addition without memory read
        RD1_E = 10; RD2_E = 20; ALUSrcE = 0; ALUOpE = 3'b010; Imm_Ext_E = 100; MemReadE = 0; #20;

        // Test 2: Subtraction with memory read
        RD1_E = 30; RD2_E = 30; ALUSrcE = 0; ALUOpE = 3'b110; Imm_Ext_E = 16; MemReadE = 1; #20;

        // Test 3: Logical AND without memory read
        RD1_E = 64'hFF00FF00; RD2_E = 64'h00FF00FF; ALUSrcE = 0; ALUOpE = 3'b000; Imm_Ext_E = 8; MemReadE = 0; #20;

        // Test 4: Logical OR with memory read
        RD1_E = 64'hFF00FF00; RD2_E = 64'h00FF00FF; ALUSrcE = 0; ALUOpE = 3'b001; Imm_Ext_E = 8; MemReadE = 1; #20;

        // Test 5: BEQ with memory read
        RD1_E = 30; RD2_E = 30; ALUSrcE = 0; BEQ_E = 1; ALUOpE = 3'b110; Imm_Ext_E = 16; PCE = 100; MemReadE = 1; #20;

        // Test 6: Immediate Operation without memory read
        RD1_E = 40; RD2_E = 50; ALUSrcE = 1; ALUOpE = 3'b010; Imm_Ext_E = 60; MemReadE = 0; #20;

        // End simulation
        $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time: %t | ALUOpE: %b | SrcA: %d | SrcB: %d | ALU_ResultM: %d | PCSrcE: %b | PCTargetE: %d | MemReadE: %b | MemReadM: %b",
                 $time, ALUOpE, uut.SrcA, uut.SrcB, ALU_ResultM, PCSrcE, PCTargetE, MemReadE, MemReadM);
    end

endmodule
