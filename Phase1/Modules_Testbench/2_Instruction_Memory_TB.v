module tb_InstructionMemory;
    reg clk;                       
    reg [63:0] address;            
    wire [31:0] instruction;       

    InstructionMemory uut (
        .clk(clk),
        .address(address),
        .instruction(instruction)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;    
    end

    initial begin
        $dumpfile("waveform.vcd"); 
        $dumpvars(0, tb_InstructionMemory); 

        address = 64'd0;            // Fetch instruction at address 0
        #10;
        address = 64'd4;            // Fetch instruction at address 4
        #10;
        address = 64'd8;            // Fetch instruction at address 8
        #10;
        address = 64'd12;            // Fetch instruction at address 12
        #10;

        $finish;                   
    end

    initial
      begin
      $monitor("Time: %0t | Address: %h | Instruction: %h", $time, address, instruction);
    end

endmodule
