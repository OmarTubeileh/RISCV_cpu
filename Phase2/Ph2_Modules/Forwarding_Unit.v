module ForwardingUnit (
    input [4:0] RS1_E,
    RS2_E,  // Source registers in EXE stage
    input [4:0] RD_M,
    RD_W,  // Destination registers from MEM and WB stages
    input RegWriteM,
    RegWriteW,  // Write enable signals
    output reg [1:0] ForwardA,
    ForwardB  // Forwarding control signals
);

  always @(*) begin
    // Default no forwarding
    ForwardA = 2'b00;
    ForwardB = 2'b00;

    // Forward from MEM stage (ALU-ALU)
    if (RegWriteM && (RD_M != 0) && (RD_M == RS1_E)) ForwardA = 2'b10;
    if (RegWriteM && (RD_M != 0) && (RD_M == RS2_E)) ForwardB = 2'b10;

    // Forward from WB stage (MEM-ALU)
    if (RegWriteW && (RD_W != 0) && (RD_W == RS1_E)) ForwardA = 2'b01;
    if (RegWriteW && (RD_W != 0) && (RD_W == RS2_E)) ForwardB = 2'b01;
  end
endmodule

// decides when and from where to forward data to the EXE stage's source registers (RS1_E and RS2_E)

// Forwarding from MEM Stage: - checks if the instruction in the MEM stage is writing to a register (RegWriteM)
//			      - ensures the destination register of the MEM stage (RD_M) matches the source registers of the EXE stage (RS1_E or RS2_E)

// Forwarding from WB Stage: - checks if the instruction in the WB stage is writing to a register (RegWriteW)
//			     - ensures the destination register of the WB stage (RD_W) matches the source registers of the EXE stage (RS1_E or RS2_E)
