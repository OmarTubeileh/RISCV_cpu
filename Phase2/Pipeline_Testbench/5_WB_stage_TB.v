module tb_WB_Stage();

    // Testbench signals
    reg clk;
    reg RegWriteW;
    reg MemToRegW;
    reg [63:0] ALU_ResultW;
    reg [63:0] ReadDataW;
    reg [4:0] RD_W;
    wire [63:0] WriteData;

    // Instantiate the WB Stage module
    WB_Stage uut (
        .clk(clk),
        .RegWriteW(RegWriteW),
        .MemToRegW(MemToRegW),
        .ALU_ResultW(ALU_ResultW),
        .ReadDataW(ReadDataW),
        .RD_W(RD_W),
        .WriteData(WriteData)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 time units
    end

    // Test sequence
    initial begin
      	// Dump waveform file
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_WB_Stage, uut);
      
        // Test Case 1: No write-back
        RegWriteW = 0;
        MemToRegW = 0;
        ALU_ResultW = 64'h123456789ABCDEF0;
        ReadDataW = 64'hFEDCBA9876543210;
        RD_W = 5'd10;
        #10;
        $display("TC1 | RegWriteW: %b | MemToRegW: %b | ALU_ResultW: %h | ReadDataW: %h | WriteData: %h", 
                  RegWriteW, MemToRegW, ALU_ResultW, ReadDataW, WriteData);

        // Test Case 2: Write ALU_ResultW to RD_W
        RegWriteW = 1;
        MemToRegW = 0; // Select ALU_ResultW
        ALU_ResultW = 64'hA1B2C3D4E5F60789;
        #10;
        $display("TC2 | RegWriteW: %b | MemToRegW: %b | ALU_ResultW: %h | ReadDataW: %h | WriteData: %h", 
                  RegWriteW, MemToRegW, ALU_ResultW, ReadDataW, WriteData);

        // Test Case 3: Write ReadDataW to RD_W
        MemToRegW = 1; // Select ReadDataW
        ReadDataW = 64'h0F1E2D3C4B5A6978;
        #10;
        $display("TC3 | RegWriteW: %b | MemToRegW: %b | ALU_ResultW: %h | ReadDataW: %h | WriteData: %h", 
                  RegWriteW, MemToRegW, ALU_ResultW, ReadDataW, WriteData);

        // Test Case 4: Write disabled
        RegWriteW = 0;
        #10;
        $display("TC4 | RegWriteW: %b | MemToRegW: %b | ALU_ResultW: %h | ReadDataW: %h | WriteData: %h", 
                  RegWriteW, MemToRegW, ALU_ResultW, ReadDataW, WriteData);

       $finish;
    end

endmodule
