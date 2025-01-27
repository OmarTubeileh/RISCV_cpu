module tb_RegisterFile;

    reg clk;                         
    reg reset;                       
    reg [4:0] read_addr1;            
    reg [4:0] read_addr2;            
    reg [4:0] write_addr;            
    reg write_enable;                
    reg [63:0] write_data;           
    wire [63:0] read_data1;          
    wire [63:0] read_data2;          

    RegisterFile uut (
        .clk(clk),
        .reset(reset),
        .read_reg1(read_addr1),
        .read_reg2(read_addr2),
        .write_reg(write_addr),
        .reg_write(write_enable),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        $dumpfile("waveform.vcd");  
        $dumpvars(0, tb_RegisterFile);

        reset = 0;
        write_enable = 0;
        read_addr1 = 5'd0;
        read_addr2 = 5'd0;
        write_addr = 5'd0;
        write_data = 64'd0;

        #10 reset = 1; // Assert reset
        #10 reset = 0; // Deassert reset

        // Test case 1: Write to a register and read it back
        write_enable = 1;
        write_addr = 5'd5;
        write_data = 64'hDEADBEEFCAFEBABE; // Write 0xDEADBEEFCAFEBABE to register 5
        #10;
        write_enable = 0;
        read_addr1 = 5'd5; // Read from register 5
        #10;

        // Test case 2: Write to another register
        write_enable = 1;
        write_addr = 5'd10;
        write_data = 64'h123456789ABCDEF0; // Write 0x123456789ABCDEF0 to register 10
        #10;
        write_enable = 0;
        read_addr2 = 5'd10; // Read from register 10
        #10;

        // Test case 3: Attempt to write to register 0 (should remain 0)
        write_enable = 1;
        write_addr = 5'd0; // Write to x0 (zero register)
        write_data = 64'hFEDCBA9876543210;
        #10;
        write_enable = 0;
        read_addr1 = 5'd0; // Read from x0 (should return 0)
        #10;

        $finish; 
    end

    initial begin
        $monitor("Time: %t | ReadAddr1: %d | ReadData1: %h | ReadAddr2: %d | ReadData2: %h | WriteAddr: %d | WriteData: %h | WriteEnable: %b",
                 $time, read_addr1, read_data1, read_addr2, read_data2, write_addr, write_data, write_enable);
    end

endmodule
