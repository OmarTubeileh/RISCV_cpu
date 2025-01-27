`include "1_Program_Counter.v"
`include "2_Instruction_Memory.v"
`include "Mux.v"

module IF_Stage(
	input clk,
	input reset,
	input PCSrc_E,
	input [63:0] PC_Target_E, 
	output wire [63:0] PC_D,
	output wire [31:0] instruction_D
);

wire [63:0] PC_F, PCF, PC_4F;
wire [31:0] instruction_F;
	
mux PC_mux(
  	.a(PC_4F),
	.b(PC_Target_E),
	.s(PCSrc_E),
	.c(PC_F)
);
	

PC pc(
	.clk(clk),
	.reset(reset),
	.pc_in(PC_F),
	.pc_out(PCF)
);

InstructionMemory instr_mem(
	.clk(clk),
	.address(PCF),
	.instruction(instruction_F)
);

assign PC_4F = PCF + 64'd4;
assign instruction_D = (reset) ? 32'd0 : instruction_F;
assign PC_D = (reset) ? 64'd0 : PCF;
	
endmodule