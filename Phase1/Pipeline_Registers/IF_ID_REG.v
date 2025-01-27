module IF_ID_REG(
	input clk,
	input reset,
	input [63:0] PC_F, 
	input [31:0] instruction_F, 
	output reg [31:0] instruction_D, 
	output reg [63:0] PC_D
);

  always @(posedge clk or posedge reset) begin
		if (reset) begin        
			PC_D <= 64'd0; 
			instruction_D = 32'd0;
		end else begin 
			PC_D <= PC_F; 
			instruction_D <= instruction_F;
		end
	end

endmodule //IF_ID_REG