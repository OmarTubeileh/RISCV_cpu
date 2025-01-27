module Adder (
    input [63:0] A,        // First input operand
    input [63:0] B,        // Second input operand
    input Cin,             // Carry-in
    output reg [63:0] Sum, // Sum output
    output reg Cout        // Carry-out
);

    reg [64:0] temp;       // Temporary register for intermediate calculation

    always @(A, B, Cin) begin
        temp = A + B + Cin;
        Sum = temp[63:0];
        Cout = temp[64];
    end

endmodule // BranchAdder
