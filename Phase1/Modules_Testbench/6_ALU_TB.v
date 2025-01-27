module tb_ALU;

    // Signals
    reg [63:0] input1;          
    reg [63:0] input2;          
    reg [3:0]  alu_control;     
    wire [63:0] result;         
    wire zero;                  

    ALU uut (
        .input1(input1),
        .input2(input2),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );

    // Test sequence
    initial begin
        $dumpfile("waveform.vcd");    
        $dumpvars(0, tb_ALU);       

        // Test case 1: Addition (4'b0010)
        input1 = 64'h0000000000000010; // 16
        input2 = 64'h0000000000000020; // 32
        alu_control = 4'b0010;         // ADD
        #10;

        // Test case 2: Subtraction (4'b0110)
        input1 = 64'h0000000000000030; // 48
        input2 = 64'h0000000000000020; // 32
        alu_control = 4'b0110;         // SUB
        #10;

        // Test case 3: AND (4'b0000)
        input1 = 64'hF0F0F0F0F0F0F0F0; // Bitmask
        input2 = 64'h0F0F0F0F0F0F0F0F; // Inverse mask
        alu_control = 4'b0000;         // AND
        #10;

        // Test case 4: OR (4'b0001)
        input1 = 64'hF0F0F0F0F0F0F0F0;
        input2 = 64'h0F0F0F0F0F0F0F0F;
        alu_control = 4'b0001;         // OR
        #10;

        // Test case 5: Set Less Than (SLT, 4'b0111)
        input1 = 64'h0000000000000010; // 16
        input2 = 64'h0000000000000020; // 32
        alu_control = 4'b0111;         // SLT
        #10;

        // Test case 6: Set Less Than Unsigned (SLTU, 4'b1000)
        input1 = 64'hFFFFFFFFFFFFFFFF; // Unsigned large
        input2 = 64'h0000000000000001; // Unsigned small
        alu_control = 4'b1000;         // SLTU
        #10;

        // Test case 7: XOR (4'b0011)
        input1 = 64'hAAAAAAAAAAAAAAAA; // Alternating bits
        input2 = 64'h5555555555555555; // Inverse alternating bits
        alu_control = 4'b0011;         // XOR
        #10;

        // Test case 8: Shift Left Logical (SLL, 4'b0100)
        input1 = 64'h0000000000000001; // 1
        input2 = 64'h0000000000000004; // Shift by 4
        alu_control = 4'b0100;         // SLL
        #10;

        // Test case 9: Shift Right Logical (SRL, 4'b0101)
        input1 = 64'h0000000000000010; // 16
        input2 = 64'h0000000000000002; // Shift by 2
        alu_control = 4'b0101;         // SRL
        #10;

        // Test case 10: Shift Right Arithmetic (SRA, 4'b1101)
        input1 = 64'h8000000000000000; // Negative number (signed)
        input2 = 64'h0000000000000004; // Shift by 4
        alu_control = 4'b1101;         // SRA
        #10;

        // Test case 11: Default case
        input1 = 64'h123456789ABCDEF0;
        input2 = 64'h0FEDCBA987654321;
        alu_control = 4'b1111;         // Unrecognized operation
        #10;

        $finish;
    end

    initial begin
        $monitor("Time: %t | Input1: %h | Input2: %h | ALU_Control: %b | Result: %h | Zero: %b",
                 $time, input1, input2, alu_control, result, zero);
    end

endmodule
