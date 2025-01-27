module tb_DataMemory;

    // Signals
    reg clk;                       
    reg mem_read;                  
    reg mem_write;                 
    reg [63:0] address;            
    reg [63:0] write_data;         
    wire [63:0] read_data;         

    DataMemory uut (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;    
    end

    initial begin
        $dumpfile("waveform.vcd");  
        $dumpvars(0, tb_DataMemory);

        mem_read = 0;
        mem_write = 0;
        address = 0;
        write_data = 0;

        // Wait for reset
        #10;

        // Test case 1: Write data to memory
        mem_write = 1;
        address = 64'h0000_0010;
        write_data = 64'hDEADBEEFCAFEBABE;
        #10;

        // Test case 2: Read data from memory
        mem_write = 0;
        mem_read = 1;
        #10;

        // Test case 3: Write another value
        mem_read = 0;
        mem_write = 1;
        address = 64'h0000_0020;
        write_data = 64'h123456789ABCDEF0;
        #10;

        // Test case 4: Read back the second value
        mem_write = 0;
        mem_read = 1;
        address = 64'h0000_0020;
        #10;

        $finish; 
    end

    initial begin
        $monitor("Time: %t | Address: %h | Write Data: %h | Read Data: %h | Mem_Read: %b | Mem_Write: %b", 
                 $time, address, write_data, read_data, mem_read, mem_write);
    end

endmodule
