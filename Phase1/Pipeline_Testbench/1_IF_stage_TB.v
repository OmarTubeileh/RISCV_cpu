module tb_IF_Stage;

    // Signals
    reg clk;
    reg reset;
    reg PCSrc_E;
    reg [63:0] PC_Target_E;
    wire [63:0] PC_D;
    wire [31:0] instruction_D;

    // Instantiate the module under test (MUT)
    IF_Stage uut (
        .clk(clk),
        .reset(reset),
        .PCSrc_E(PCSrc_E),
        .PC_Target_E(PC_Target_E),
        .PC_D(PC_D),
        .instruction_D(instruction_D)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns clock period
    end

    // Test sequence
    initial begin
        $dumpfile("IF_Stage_waveform.vcd"); // Dump waveform for viewing
        $dumpvars(0, tb_IF_Stage);

        // Initialize signals
        reset = 1;          // Assert reset
        PCSrc_E = 0;        // Default to sequential fetch
        PC_Target_E = 64'd0; // Default branch target

        #10 reset = 0; // Deassert reset after 10 ns

        // Test case 1: Sequential fetch
        PCSrc_E = 0;
        #20; // Wait for two cycles

        // Test case 2: Branch taken
        PCSrc_E = 1;
        PC_Target_E = 64'd16; // Jump to address 16
        #10;
        PCSrc_E = 0; // Back to sequential
        #20;

        // Test case 3: Reset during operation
        reset = 1;
        #10 reset = 0;

        $finish; // End simulation
    end

    // Monitor results
    initial begin
      $monitor("Time: %0t | Reset: %b | PCSrc_E: %b | PC_Target_E: %h | PC_D: %h | Instruction_D: %h",
                 $time, reset, PCSrc_E, PC_Target_E, PC_D, instruction_D);
    end

endmodule
