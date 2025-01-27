module tb_MEM_Stage;

    // Testbench signals
    reg clk;
    reg reset;
    reg RegWriteM, MemWriteM, MemReadM, MemtoRegM;
    reg [63:0] ALU_ResultM;
    reg [63:0] WriteDataM;
    reg [4:0] RD_M;
    wire RegWriteW, MemtoRegW;
    wire [63:0] ReadDataW;
    wire [63:0] ALU_ResultW;
    wire [4:0] RD_W;

    // Instantiate the MEM_Stage module
    MEM_Stage uut (
        .clk(clk),
        .reset(reset),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .MemReadM(MemReadM),
        .MemtoRegM(MemtoRegM),
        .ALU_ResultM(ALU_ResultM),
        .WriteDataM(WriteDataM),
        .RD_M(RD_M),
        .RegWriteW(RegWriteW),
        .MemtoRegW(MemtoRegW),
        .ReadDataW(ReadDataW),
        .ALU_ResultW(ALU_ResultW),
        .RD_W(RD_W)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period = 10 ns
    end

    // Test sequence
    initial begin
        // Initialize signals
        reset = 1;
        RegWriteM = 0;
        MemWriteM = 0;
        MemReadM = 0;
        MemtoRegM = 0;
        ALU_ResultM = 64'b0;
        WriteDataM = 64'b0;
        RD_M = 5'b0;

        // Dump waveforms
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_MEM_Stage);

        // Test 1: Reset the system
        #10 reset = 0;

        // Test 2: Write to memory
        MemWriteM = 1;
        ALU_ResultM = 8; // Memory address
        WriteDataM = 64'hABCDEF0123456789;
        #10 MemWriteM = 0;

        // Test 3: Read from memory
        MemReadM = 1;
        MemtoRegM = 1;
        RegWriteM = 1;
        RD_M = 5'b00001; // Destination register
        ALU_ResultM = 8; // Same address
        #10 MemReadM = 0;

        // Test 4: Forward ALU result to WB stage
        MemtoRegM = 0; // Bypass memory read
        ALU_ResultM = 64'h12345678ABCDEF00;
        RD_M = 5'b00010; // Another destination register
        #10;

        // Test 5: Reset the system
        reset = 1;
        #10 reset = 0;

        // Finish simulation
        #50 $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | RegWriteW: %b | MemtoRegW: %b | ReadDataW: %h | ALU_ResultW: %h | RD_W: %b",
                 $time, RegWriteW, MemtoRegW, ReadDataW, ALU_ResultW, RD_W);
    end

endmodule
