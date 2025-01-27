module tb_PC;

    // Signals
    reg clk;                      
    reg reset;                  
    reg [63:0] pc_in;             
    wire [63:0] pc_out;           

    PC uut (
        .clk(clk),                
        .reset(reset),          
        .pc_in(pc_in),          
        .pc_out(pc_out)         
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;    
    end

    initial begin
        $dumpfile("waveform.vcd"); 
        $dumpvars(0, tb_PC);      

        reset = 0;              
        pc_in = 64'd0;            
        #10 reset = 1;          

        // Test case 1: Increment PC
        pc_in = 64'd4;
        #10;

        // Test case 2: Increment further
        pc_in = 64'd8;
        #10;

        // Test case 3: Reset
        reset = 0;
        #10 reset = 1;

        $finish;                  
    end

    initial begin
        $monitor("Time: %t | pc_in: %d | pc_out: %d", 
                 $time, pc_in, pc_out);
    end

endmodule
