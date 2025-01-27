
module HazardDetectionUnit (
    input      [4:0] ID_EX_Rd,         // Destination register in EX stage
    input            ID_EX_MemRead,    // Memory read enable in EX stage
    input            ID_EX_RegWrite,   // Register write enable in EX stage
    input            branch_taken_ID,  // Branch taken signal from ID stage
    input      [4:0] IF_ID_Rs1,        // Source register 1 in ID stage
    input      [4:0] IF_ID_Rs2,        // Source register 2 in ID stage
    output reg       PCWrite,          // Control signal to enable/disable PC update
    output reg       IF_ID_Write,      // Control signal to enable/disable IF/ID register update
    output reg       Stall             // Control signal to stall pipeline
);

  always @(*) begin
    // Default values: No stall
    PCWrite = 1'b1;
    IF_ID_Write = 1'b1;
    Stall = 1'b0;

    // RAW Data Hazard Detection (Read-After-Right)
    if (ID_EX_MemRead && ((ID_EX_Rd == IF_ID_Rs1) || (ID_EX_Rd == IF_ID_Rs2))) begin
      PCWrite     = 1'b0;  // Stop PC update
      IF_ID_Write = 1'b0;  // Stop IF/ID register update
      Stall       = 1'b1;  // Insert bubble (stall signal)
    end  
    // Control Hazard Detection (Branch Taken)
    else if (branch_taken_ID) begin
      PCWrite     = 1'b0;  // Stop PC update
      IF_ID_Write = 1'b0;  // Stop IF/ID register update
      Stall       = 1'b1;  // Insert bubble (stall signal)
    end
  end
endmodule

// forwarding solved the R-type to R-type hazard, but the Load/Store needs to have one cycle stall