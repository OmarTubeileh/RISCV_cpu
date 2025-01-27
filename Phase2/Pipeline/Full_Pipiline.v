`include "1_IF_stage.v"
`include "2_ID_stage.v"
`include "3_EXE_stage.v"
`include "4_MEM_stage.v"
`include "5_WB_stage.v"
`include "IF_ID_REG.v"
`include "ID_EXE_REG.v"
`include "EXE_MEM_REG.v"
`include "MEM_WB_REG.v"
`include "Hazard_Detection_Unit.v"


module Full_Pipeline (
    input clk,
    input reset
);

  // ================================
  //      IF (Instruction Fetch) 
  // ================================
  wire        branch_taken_EXE;  // Branch decision from EXE stage
  wire [63:0] branch_target_addr_EXE;  // Branch target address from EXE stage
  wire [63:0] program_counter_IF;  // Program Counter output from IF stage
  wire [31:0] instruction_IF;  // Fetched instruction from instruction memory

  wire branch_resolved, actual_taken;
  wire [63:0] branch_target_resolved, branch_pc;

  wire PCWrite;  // Hazard detection control signal

  IF_Stage if_stage (
      .clk                   (clk),
      .reset                 (reset),
      .PCSrc_E               (branch_taken_EXE),        // Branch decision from EXE stage
      .PC_Target_E           (branch_target_addr_EXE),  // Branch target address
      .branch_resolved       (branch_resolved),
      .actual_taken          (actual_taken),
      .branch_pc             (branch_pc),
      .branch_target_resolved(branch_target_resolved),
      .PCWrite               (PCWrite),                 // Control signal from HDU
      .PC_D                  (program_counter_IF),      // Program Counter output for IF/ID register
      .instruction_D         (instruction_IF)           // Fetched instruction for IF/ID register
  );


  // ================================
  //      IF/ID Pipeline Register 
  // ================================
  wire [63:0] program_counter_ID;  // Program Counter passed to ID stage
  wire [31:0] instruction_ID;  // Instruction passed to ID stage

  wire        IF_ID_Write;  // Hazard control signal
  IF_ID_REG if_id_reg (
      .clk          (clk),
      .reset        (reset),
      .IF_ID_Write  (IF_ID_Write),         // Hazard control
      .PC_F         (program_counter_IF),  // Program Counter from IF stage
      .instruction_F(instruction_IF),      // Instruction from IF stage
      .instruction_D(instruction_ID),      // Instruction output to ID stage
      .PC_D         (program_counter_ID)   // Program Counter output to ID stage
  );

  // ================================
  //      ID (Instruction Decode)   
  // ================================
  wire [63:0] write_data_WB;  // Data to be written to the register file
  wire [63:0] reg_data1_ID, reg_data2_ID;  // Read data from registers    
  wire [4:0] rs1_ID, rs2_ID, rd_ID;  // Source and destination register addresses
  wire [ 4:0] write_register_WB;  // Destination register for WB stage
  wire        reg_write_enable_WB;  // Register write enable signal from WB stage

  wire [63:0] immediate_value_ID;  // Immediate value from instruction decoding

  wire [ 3:0] alu_operation_ID;  // ALU operation control
  wire        alu_src_select_ID;  // Select immediate or register as ALU operand

  wire        memory_read_enable_ID;  // Signal to enable memory read
  wire        memory_read;  // Signal to read from memory
  wire        memory_to_register_ID;  // Signal to select memory data for WB
  wire        memory_write_enable_ID;  // Signal to enable memory write
  wire        reg_write_enable_ID;  // Register write enable
  wire [ 1:0] MemType;  // Byte, Half, Word, Double

  wire branch_eq_ID, branch_ne_ID;  // Branch control signals
  wire jump_enable_ID, jump_register_enable_ID;  // Jump signals

  wire branch_taken_ID;  // Branch taken decision

  // Exception signals
  wire flush_pipeline, jump_to_handler;
  wire [31:0] SCAUSE;
  wire [63:0] SEPC;

  ID_Stage id_stage (
      .clk            (clk),
      .reset          (reset),
      .instruction_D  (instruction_ID),           // Instruction from IF/ID pipeline register
      .PC_D           (program_counter_ID),       // Program Counter from IF/ID register
      .write_data     (write_data_WB),            // Write data from WB stage
      .write_reg      (write_register_WB),        // Destination register from WB stage
      .reg_write      (reg_write_enable_WB),      // Register write enable from WB stage
      .data_rs1       (reg_data1_ID),             // Read data1 output to EXE stage
      .data_rs2       (reg_data2_ID),             // Read data2 output to EXE stage
      .imm_val        (immediate_value_ID),       // Immediate value output to EXE stage
      .rs1            (rs1_ID),                   // Source register 1 address
      .rs2            (rs2_ID),                   // Source register 2 address
      .rd             (rd_ID),                    // Destination register address
      .ALUop          (alu_operation_ID),         // ALU operation control output
      .MemReadEn      (memory_read_enable_ID),    // Memory read enable
      .Mem_Read       (memory_read),              // Read from memory
      .MemToReg       (memory_to_register_ID),    // Select memory data for WB
      .MemWriteEn     (memory_write_enable_ID),   // Memory write enable
      .ALUSrc         (alu_src_select_ID),        // ALU source select
      .RegWrite       (reg_write_enable_ID),      // Register write enable
      .MemTypeD       (MemType),                  // Pass MemType to EXE
      .BEQ            (branch_eq_ID),             // Branch if equal
      .BNE            (branch_ne_ID),             // Branch if not equal
      .JALen          (jump_enable_ID),           // Jump enable
      .JALRen         (jump_register_enable_ID),  // Jump and link register enable
      .branch_taken   (branch_taken_ID),          // Branch decision output
      .flush_pipeline (flush_pipeline),
      .jump_to_handler(jump_to_handler),
      .SCAUSE         (SCAUSE),
      .SEPC           (SEPC)
  );


  // ================================
  //      Hazard Detection Unit
  // ================================
  wire       Stall;  // Stall signal for pipeline
  wire [4:0] rd_EXE;  // Destination register address
  wire       memory_read_enable_EXE;  // Memory read enable in EXE stage
  wire       reg_write_enable_EXE;  // Register write enable in EXE stage

  HazardDetectionUnit hdu (
      .ID_EX_Rd(rd_EXE),
      .ID_EX_MemRead(memory_read_enable_EXE),
      .ID_EX_RegWrite(reg_write_enable_EXE),
      .branch_taken_ID(branch_taken_ID),
      .IF_ID_Rs1(rs1_ID),
      .IF_ID_Rs2(rs2_ID),
      .PCWrite(PCWrite),
      .IF_ID_Write(IF_ID_Write),
      .Stall(Stall)
  );

  // ================================
  //      ID/EX Pipeline Register
  // ================================
  wire [63:0] reg_data1_EXE, reg_data2_EXE;  // Register data inputs

  wire        memory_write_enable_EXE;  // Memory write enable in EXE stage
  wire        memory_to_register_EXE;  // Select memory data for WB

  wire        alu_src_select_EXE;  // ALU source select in EXE stage
  wire [ 3:0] alu_operation_EXE;  // ALU operation control

  wire [63:0] program_counter_EXE;  // Program Counter for EXE stage
  wire [63:0] immediate_value_EXE;  // Immediate value input

  wire branch_eq_EXE, branch_ne_EXE;  // Branch control signals
  wire jump_enable_EXE, jump_register_enable_EXE;  // Jump signals

  ID_EXE_REG id_exe_reg (
      .clk       (clk),
      .reset     (reset || flush_pipeline),
      .Stall     (Stall),                     // Hazard control signal
      .RegWriteD (reg_write_enable_ID),
      .ALUSrcD   (alu_src_select_ID),
      .MemWriteD (memory_write_enable_ID),
      .MemReadD  (memory_read_enable_ID),
      .Mem_ReadD (memory_read),
      .ResultSrcD(memory_to_register_ID),
      .MemTypeD  (MemType),
      .ALUOpD    (alu_operation_ID),
      .RD1_D     (reg_data1_ID),
      .RD2_D     (reg_data2_ID),
      .Imm_D     (immediate_value_ID),
      .RD_D      (rd_ID),
      .PCD       (program_counter_ID),
      .BEQ_D     (branch_eq_ID),
      .BNE_D     (branch_ne_ID),
      .JAL_D     (jump_enable_ID),
      .JALR_D    (jump_register_enable_ID),
      .RS1_D     (rs1_ID),
      .RS2_D     (rs1_ID),
      .RegWriteE (reg_write_enable_EXE),
      .ALUSrcE   (alu_src_select_EXE),
      .MemWriteE (memory_write_enable_EXE),
      .MemReadE  (memory_read_enable_EXE),
      .Mem_ReadE (memory_read),
      .ResultSrcE(memory_to_register_EXE),
      .MemTypeE  (MemType),
      .ALUOpE    (alu_operation_EXE),
      .RD1_E     (reg_data1_EXE),
      .RD2_E     (reg_data2_EXE),
      .Imm_E     (immediate_value_EXE),
      .RD_E      (rd_EXE),
      .PCE       (program_counter_EXE),
      .BEQ_E     (branch_eq_EXE),
      .BNE_E     (branch_ne_EXE),
      .JAL_E     (jump_enable_EXE),
      .JALR_E    (jump_register_enable_EXE),
      .RS1_E     (rs1_ID),
      .RS2_E     (rs1_ID)
  );

  // ================================
  //      EXE (Execute) Stage
  // ================================
  wire [63:0] alu_result_MEM;  // Result from ALU for MEM stage
  wire [63:0] write_data_MEM;  // Data to be written to memory
  wire        reg_write_enable_MEM;  // Register write enable in MEM stage
  wire        memory_write_enable_MEM;  // Memory write enable in MEM stage
  wire        memory_read_enable_MEM;  // Memory read enable in MEM stage
  wire        memory_to_register_MEM;  // Select memory data for WB
  wire [ 4:0] rd_MEM;  // Destination register address in MEM stage

  EXE_Stage exe_stage (
      .clk      (clk),
      .reset    (reset || flush_pipeline),
      .RegWriteE(reg_write_enable_EXE),     // Register write enable from ID/EXE
      .ALUSrcE  (alu_src_select_EXE),       // ALU source select from ID/EXE
      .MemWriteE(memory_write_enable_EXE),  // Memory write enable from ID/EXE
      .MemToRegE(memory_to_register_EXE),   // Memory-to-register select from ID/EXE
      .MemReadE (memory_read_enable_EXE),   // Memory read enable from ID/EXE
      .Mem_ReadE(memory_read),
      .MemTypeE (MemType),
      .ALUOpE   (alu_operation_EXE),        // ALU operation control from ID/EXE
      .RD1_E    (reg_data1_EXE),            // Register data 1 from ID/EXE
      .RD2_E    (reg_data2_EXE),            // Register data 2 from ID/EXE
      .Imm_E    (immediate_value_EXE),      // Immediate value from ID/EXE
      .RD_E     (rd_EXE),                   // Destination register from ID/EXE
      .PCE      (program_counter_EXE),      // Program Counter from ID/EXE
      .BEQ_E    (branch_eq_EXE),            // Branch if equal from ID/EXE
      .BNE_E    (branch_ne_EXE),            // Branch if not equal from ID/EXE
      .JAL_E    (jump_enable_EXE),          // Jump enable from ID/EXE
      .JALR_E   (jump_register_enable_EXE), // Jump and link register enable from ID/EXE  

      .RS1_E      (rs1_ID),                // Forward RS1 to EXE Stage
      .RS2_E      (rs2_ID),                // Forward RS2 to EXE Stage
      .RD_M       (rd_MEM),                // Forward RD from MEM stage
      .RD_W       (write_register_WB),     // Forward RD from WB stage
      .RegWriteM  (reg_write_enable_MEM),
      .RegWriteW  (reg_write_enable_WB),
      .ALU_ResultM(alu_result_MEM),
      .WriteDataW (write_data_WB),

      .PCSrcE         (branch_taken_EXE),         // Branch decision output
      .RegWriteM_out  (reg_write_enable_MEM),     // Register write enable to MEM
      .MemWriteM_out  (memory_write_enable_MEM),  // Memory write enable to MEM
      .MemToRegM_out  (memory_to_register_MEM),   // Memory-to-register select to MEM
      .MemReadM_out   (memory_read_enable_MEM),   // Memory read enable to MEM
      .Mem_ReadM_out  (memory_read),
      .MemTypeM_out   (MemType),
      .RD_M_out       (rd_MEM),                   // Destination register to MEM
      .WriteDataM_out (write_data_MEM),           // Data to write to memory
      .ALU_ResultM_out(alu_result_MEM),           // ALU result to MEM
      .PCTargetE      (branch_target_addr_EXE)    // Branch target address
  );

  // ================================
  //      EXE/MEM Pipeline Register 
  // ================================
  wire [63:0] alu_result_MEM_stage;  // ALU result passed to MEM stage
  wire [63:0] write_data_MEM_stage;  // Data to write passed to MEM stage
  wire [ 4:0] rd_MEM_stage;  // Destination register address in MEM stage

  EXE_MEM_REG exe_mem_reg (
      .clk       (clk),
      .reset     (reset || flush_pipeline),
      .RegWriteE (reg_write_enable_MEM),     // Register write enable from EXE
      .MemWriteE (memory_write_enable_MEM),  // Memory write enable from EXE
      .MemToRegE (memory_to_register_MEM),   // Memory-to-register select from EXE
      .MemReadE  (memory_read_enable_MEM),   // Memory read enable from EXE
      .Mem_ReadE (memory_read),
      .MemTypeE  (MemType),
      .ALUResultE(alu_result_MEM),           // ALU result from EXE
      .WriteDataE(write_data_MEM),           // Write data from EXE
      .RD_E      (rd_MEM),                   // Destination register from EXE
      .PCSrcE    (branch_taken_EXE),         // Branch decision
      .PCTargetE (branch_target_addr_EXE),   // Branch target address
      .RegWriteM (reg_write_enable_MEM),     // Register write enable to MEM
      .MemWriteM (memory_write_enable_MEM),  // Memory write enable to MEM
      .MemToRegM (memory_to_register_MEM),   // Memory-to-register select to MEM
      .MemReadM  (memory_read_enable_MEM),   // Memory read enable to MEM
      .Mem_ReadM (memory_read),
      .MemTypeM  (MemType),
      .ALUResultM(alu_result_MEM_stage),     // ALU result to MEM stage
      .WriteDataM(write_data_MEM_stage),     // Write data to MEM stage
      .RD_M      (rd_MEM_stage),             // Destination register to MEM stage
      .PCSrcM    (branch_taken_EXE),
      .PCTargetM (branch_target_addr_EXE)
  );

  // ================================
  //      MEM (Memory Access) Stage
  // ================================
  wire [63:0] read_data_WB;  // Data read from memory for WB stage
  wire [ 4:0] rd_WB;  // Destination register address in WB stage
  wire        memory_to_register_WB;  // Memory-to-register select in WB stage

  MEM_Stage mem_stage (
      .clk        (clk),
      .reset      (reset || flush_pipeline),
      .RegWriteM  (reg_write_enable_MEM),     // Register write enable from EXE/MEM
      .MemWriteM  (memory_write_enable_MEM),  // Memory write enable from EXE/MEM
      .MemReadM   (memory_read_enable_MEM),   // Memory read enable from EXE/MEM
      //.Mem_ReadM(memory_read),
      .MemtoRegM  (memory_to_register_MEM),   // Memory-to-register select from EXE/MEM
      .MemTypeM   (MemType),
      .ALU_ResultM(alu_result_MEM_stage),     // ALU result from EXE/MEM
      .WriteDataM (write_data_MEM_stage),     // Data to write from EXE/MEM
      .RD_M       (rd_MEM_stage),             // Destination register from EXE/MEM
      .RegWriteW  (reg_write_enable_WB),      // Register write enable to WB
      .MemtoRegW  (memory_to_register_WB),    // Memory-to-register select to WB
      .ReadDataW  (read_data_WB),             // Data read from memory to WB
      .RD_W       (rd_WB)                     // Destination register to WB
  );

  // ================================
  //      MEM/WB Pipeline Register
  // ================================
  wire [63:0] alu_result_WB;  // ALU result passed to WB stage

  MEM_WB_REG mem_wb_reg (
      .clk        (clk),
      .reset      (reset || flush_pipeline),
      .RegWriteM  (reg_write_enable_WB),      // Register write enable from MEM
      .MemToRegM  (memory_to_register_WB),    // Memory-to-register select from MEM
      .ReadDataM  (read_data_WB),             // Data read from memory in MEM
      .ALU_ResultM(alu_result_MEM_stage),     // ALU result from MEM
      .RD_M       (rd_WB),                    // Destination register from MEM
      .RegWriteW  (reg_write_enable_WB),      // Register write enable to WB
      .MemToRegW  (memory_to_register_WB),    // Memory-to-register select to WB
      .ReadDataW  (read_data_WB),             // Data read from memory to WB
      .ALU_ResultW(alu_result_WB),            // ALU result to WB
      .RD_W       (write_register_WB)         // Destination register to WB
  );

  // ================================
  //      WB (Write Back) Stage
  // ================================
  WB_Stage wb_stage (
      .clk        (clk),
      .RegWriteW  (reg_write_enable_WB),    // Register write enable from MEM/WB
      .MemToRegW  (memory_to_register_WB),  // Memory-to-register select from MEM/WB
      .ALU_ResultW(alu_result_WB),          // ALU result from MEM/WB
      .ReadDataW  (read_data_WB),           // Data read from memory in MEM/WB
      .RD_W       (write_register_WB),      // Destination register in WB
      .WriteData  (write_data_WB)           // Data to write to register file
  );

endmodule

