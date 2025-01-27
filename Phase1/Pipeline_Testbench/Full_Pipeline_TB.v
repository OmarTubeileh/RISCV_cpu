module Full_Pipeline_tb;

    reg clk, reset;
    Full_Pipeline uut (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        // Clock generation
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    initial begin
        // Test sequence
        reset = 1;
        #10 reset = 0;  // Release reset after 10ns
        
        // Simulate for a few cycles
        #100;

        // End simulation
        $stop;
    end

endmodule
