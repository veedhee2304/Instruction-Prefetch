`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// pipe_mips32_prefetch_fixed.v
// Single-clock 5-stage pipeline with prefetch FIFO, simple bandwidth-limited prefetch engine,
// load-use stall, forwarding, and branch flush.
// Synthesizable style: single clock, synchronous reset, nonblocking assignments.
//////////////////////////////////////////////////////////////////////////////////

module instr_fifo #(
  parameter WIDTH = 32,
  parameter DEPTH = 8,
  parameter ADDR_W = 3
)(
  input  wire               clk,
  input  wire               reset,
  // push side (prefetch engine)
  input  wire               push,
  input  wire [WIDTH-1:0]   push_data,
  output wire               full,
  // pop side (IF stage)
  input  wire               pop,
  output wire [WIDTH-1:0]   pop_data,
  output wire               empty,
  output wire [ADDR_W:0]    count_out
);
  // simple synchronous FIFO
  reg [WIDTH-1:0] mem [0:DEPTH-1];
  reg [ADDR_W-1:0] wr_ptr, rd_ptr;
  reg [ADDR_W:0] count;

  assign full = (count == DEPTH);
  assign empty = (count == 0);
  assign pop_data = mem[rd_ptr];
  assign count_out = count;

  always @(posedge clk) begin
    if (reset) begin
      wr_ptr <= 0;
      rd_ptr <= 0;
      count <= 0;
    end else begin
      // push
      if (push && !full) begin
        mem[wr_ptr] <= push_data;
        wr_ptr <= wr_ptr + 1;
        count <= count + 1;
      end
      // pop
      if (pop && !empty) begin
        rd_ptr <= rd_ptr + 1;
        count <= count - 1;
      end
    end
  end
endmodule


module pipe_MIPS32_prefetch #(
  parameter INSTR_FIFO_DEPTH = 8,
  parameter MAX_OUTSTANDING = 2, // fetch bandwidth (outstanding requests)
  parameter MEM_LATENCY = 2,     // cycles between request and response
  parameter MEM_SIZE = 1024
)(
  input  wire clk,
  input  wire reset
);
  // Opcodes (6 bits)
  localparam [5:0] ADD   = 6'b000000,
                   SUB   = 6'b000001,
                   ANDI  = 6'b000010,
                   OR    = 6'b000011,
                   SLT   = 6'b000100,
                   MUL   = 6'b000101,
                   HLT   = 6'b111111,
                   LW    = 6'b001000,
                   SW    = 6'b001001,
                   ADDI  = 6'b001010,
                   SUBI  = 6'b001011,
                   SLTI  = 6'b001100,
                   BNEQZ = 6'b001101,
                   BEQZ  = 6'b001110;

  // Types
  localparam [2:0] RR_ALU = 3'b000,
                   RM_ALU = 3'b001,
                   LOAD   = 3'b010,
                   STORE  = 3'b011,
                   BRANCH = 3'b100,
                   HALT   = 3'b101,
                   NOP_T  = 3'b110;

  // Pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB)
  reg [31:0] PC;
  reg [31:0] IF_ID_IR, IF_ID_NPC;

  reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
  reg [2:0]  ID_EX_type;

  reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;
  reg        EX_MEM_cond;
  reg [2:0]  EX_MEM_type;

  reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;
  reg [2:0]  MEM_WB_type;

  reg HALTED;
  // registers and memory
  reg [31:0] RegFile [0:31];
  reg [31:0] Mem     [0:MEM_SIZE-1];

  // Prefetch structures
  wire fifo_full, fifo_empty;
  wire [31:0] fifo_data_out;
  reg fifo_pop;
  reg fifo_push;
  reg [31:0] fifo_push_data;
  wire [3:0] fifo_count; // adapt width if needed

  // compute address width for FIFO (small helper)
  localparam FIFO_ADDR_W = (INSTR_FIFO_DEPTH <= 8) ? 3 : 4;

  instr_fifo #(
    .WIDTH(32),
    .DEPTH(INSTR_FIFO_DEPTH),
    .ADDR_W(FIFO_ADDR_W)
  ) instr_fifo0 (
    .clk(clk),
    .reset(reset),
    .push(fifo_push),
    .push_data(fifo_push_data),
    .full(fifo_full),
    .pop(fifo_pop),
    .pop_data(fifo_data_out),
    .empty(fifo_empty),
    .count_out(fifo_count)
  );

  // Simple outstanding request tracker and response pipeline to model memory latency
  reg [7:0] outstanding;
  // response pipe: store data and valid flags
  reg [31:0] resp_pipe [0:MEM_LATENCY-1];
  reg        resp_valid_pipe [0:MEM_LATENCY-1];

  // Temporary forwarding destination/flags (declared at module scope for Verilog compatibility)
  reg [4:0] exmem_dest;
  reg       exmem_will_write;
  reg [4:0] memwb_dest;
  reg       memwb_will_write;

  integer i;
  // Initialize memories on reset
  always @(posedge clk) begin
    if (reset) begin
      for (i = 0; i < 32; i = i+1) RegFile[i] <= 0;
      for (i = 0; i < MEM_SIZE; i = i+1) Mem[i] <= 32'b0;
      PC <= 0;
      IF_ID_IR <= 32'b0;
      IF_ID_NPC <= 32'b0;
      ID_EX_IR <= 32'b0;
      ID_EX_NPC <= 32'b0;
      ID_EX_A <= 32'b0;
      ID_EX_B <= 32'b0;
      ID_EX_Imm <= 32'b0;
      EX_MEM_IR <= 32'b0;
      EX_MEM_ALUOut <= 32'b0;
      EX_MEM_B <= 32'b0;
      EX_MEM_cond <= 0;
      MEM_WB_IR <= 32'b0;
      MEM_WB_ALUOut <= 32'b0;
      MEM_WB_LMD <= 32'b0;
      HALTED <= 0;
      outstanding <= 0;
      for (i = 0; i < MEM_LATENCY; i = i+1) begin
        resp_pipe[i] <= 32'b0;
        resp_valid_pipe[i] <= 1'b0;
      end
      fifo_push <= 0;
      fifo_pop <= 0;
    end else begin
      // default control signals between cycles
      fifo_push <= 0;
      fifo_pop <= 0;
    end
  end

  // Prefetch pointer (separate from CPU PC)
  reg [31:0] prefetch_ptr;
  always @(posedge clk) begin
    if (reset) begin
      prefetch_ptr <= 0;
    end else begin
      // Issue a prefetch request when FIFO has space and we have bandwidth
      if (!fifo_full && (outstanding < MAX_OUTSTANDING) && !HALTED) begin
        outstanding <= outstanding + 1;
        resp_pipe[0] <= Mem[prefetch_ptr];
        resp_valid_pipe[0] <= 1'b1;
        prefetch_ptr <= prefetch_ptr + 1;
      end 
//      else begin
//        // keep resp_pipe[0] unchanged if not issuing
//        resp_pipe[0] <= resp_pipe[0];
//        resp_valid_pipe[0] <= resp_valid_pipe[0];
//      end

      // shift response pipeline forward
      for (i = MEM_LATENCY-1; i > 0; i = i - 1) begin
        resp_pipe[i] <= resp_pipe[i-1];
        resp_valid_pipe[i] <= resp_valid_pipe[i-1];
      end

      // If a response emerges from the last stage, push into FIFO (if space)
      if (resp_valid_pipe[MEM_LATENCY-1]) begin
        if (!fifo_full) begin
          fifo_push <= 1;
          fifo_push_data <= resp_pipe[MEM_LATENCY-1];
          outstanding <= (outstanding > 0) ? outstanding - 1 : 0;
          resp_valid_pipe[MEM_LATENCY-1] <= 0;
        end
        // if FIFO full, backpressure (leave resp_valid high)
      end
    end
  end

  // IF stage control
  reg stall; // load-use stall
  reg flush_if_id; // not used now but left for clarity
  // Branch signals resolved in MEM stage (EX -> MEM move)
  reg branch_taken;
  reg [31:0] branch_target;

  // Hazard detection (load-use)
  wire [4:0] id_rs = IF_ID_IR[25:21];
  wire [4:0] id_rt = IF_ID_IR[20:16];
  wire ex_is_load = (ID_EX_type == LOAD);
  wire [4:0] ex_dest_reg = ID_EX_IR[20:16]; // load writes to rt
  wire load_use_stall = ex_is_load &&
                        ( (ex_dest_reg != 5'b00000) &&
                          ( (ex_dest_reg == id_rs) || (ex_dest_reg == id_rt) ) );

  // Register file combinational read
  wire [31:0] reg_rs = (id_rs == 5'b00000) ? 32'b0 : RegFile[id_rs];
  wire [31:0] reg_rt = (id_rt == 5'b00000) ? 32'b0 : RegFile[id_rt];

  // ID stage sequential: capture operands & decode
  always @(posedge clk) begin
    if (reset) begin
      ID_EX_IR <= 32'b0;
      ID_EX_NPC <= 32'b0;
      ID_EX_A <= 32'b0;
      ID_EX_B <= 32'b0;
      ID_EX_Imm <= 32'b0;
      ID_EX_type <= NOP_T;
      branch_taken <= 0;
      branch_target <= 0;
      stall <= 0;
    end else begin
      if (HALTED) begin
        ID_EX_IR <= 32'b0;
        ID_EX_type <= HALT;
      end else begin
        if (load_use_stall) begin
          // insert bubble in ID/EX and stall IF
          ID_EX_IR <= 32'b0;
          ID_EX_type <= NOP_T;
          ID_EX_NPC <= IF_ID_NPC;
          ID_EX_A <= 0;
          ID_EX_B <= 0;
          ID_EX_Imm <= 0;
          stall <= 1;
        end else begin
          stall <= 0;
          ID_EX_IR <= IF_ID_IR;
          ID_EX_NPC <= IF_ID_NPC;
          ID_EX_A <= reg_rs;
          ID_EX_B <= reg_rt;
          ID_EX_Imm <= {{16{IF_ID_IR[15]}}, IF_ID_IR[15:0]};
          case (IF_ID_IR[31:26])
            ADD, SUB, ANDI, OR, SLT, MUL:
              ID_EX_type <= RR_ALU;
            ADDI, SUBI, SLTI:
              ID_EX_type <= RM_ALU;
            LW:
              ID_EX_type <= LOAD;
            SW:
              ID_EX_type <= STORE;
            BNEQZ, BEQZ:
              ID_EX_type <= BRANCH;
            HLT:
              ID_EX_type <= HALT;
            default:
              ID_EX_type <= NOP_T;
          endcase
        end
      end
    end
  end

  // IF stage sequential: fetch from FIFO when available
  always @(posedge clk) begin
    if (reset) begin
      IF_ID_IR <= 32'b0;
      IF_ID_NPC <= 32'b0;
      PC <= 0;
    end else begin
      if (HALTED) begin
        fifo_pop <= 0;
      end else begin
        if (branch_taken) begin
          // flush IF/ID and set PC to branch target
          IF_ID_IR <= 32'b0;
          IF_ID_NPC <= 0;
          PC <= branch_target;
          branch_taken <= 0;
        end else if (stall) begin
          // hold IF/ID and do not advance PC
          fifo_pop <= 0;
        end else begin
          if (!fifo_empty) begin
            fifo_pop <= 1;
            IF_ID_IR <= fifo_data_out;
            IF_ID_NPC <= PC + 1;
            PC <= PC + 1;
          end else begin
            fifo_pop <= 0;
            IF_ID_IR <= 32'b0;
            IF_ID_NPC <= PC;
          end
        end
      end
    end
  end

  // EX stage forwarding control (combinational)
  reg [1:0] forwardA_sel; // 00 = reg, 01 = EX/MEM, 10 = MEM/WB
  reg [1:0] forwardB_sel;

  // EX stage forwarding control (combinational)
    always @(*) begin
        // defaults
        forwardA_sel = 2'b00;
        forwardB_sel = 2'b00;
    
        // compute EX/MEM destination & write flag
        exmem_will_write = 1'b0;
        exmem_dest = 5'b00000;
    
        case (EX_MEM_type)
            RR_ALU: begin exmem_will_write = 1'b1; exmem_dest = EX_MEM_IR[15:11]; end
            RM_ALU: begin exmem_will_write = 1'b1; exmem_dest = EX_MEM_IR[20:16]; end
            LOAD:   begin exmem_will_write = 1'b1; exmem_dest = EX_MEM_IR[20:16]; end
        endcase
    
        // MEM/WB
        memwb_will_write = 1'b0;
        memwb_dest = 5'b00000;
    
        case (MEM_WB_type)
            RR_ALU: begin memwb_will_write = 1'b1; memwb_dest = MEM_WB_IR[15:11]; end
            RM_ALU: begin memwb_will_write = 1'b1; memwb_dest = MEM_WB_IR[20:16]; end
            LOAD:   begin memwb_will_write = 1'b1; memwb_dest = MEM_WB_IR[20:16]; end
        endcase
    
        // Forward A
        if (exmem_will_write && exmem_dest != 0 && exmem_dest == ID_EX_IR[25:21])
            forwardA_sel = 2'b01;
        else if (memwb_will_write && memwb_dest != 0 && memwb_dest == ID_EX_IR[25:21])
            forwardA_sel = 2'b10;
    
        // Forward B
        if (exmem_will_write && exmem_dest != 0 && exmem_dest == ID_EX_IR[20:16])
            forwardB_sel = 2'b01;
        else if (memwb_will_write && memwb_dest != 0 && memwb_dest == ID_EX_IR[20:16])
            forwardB_sel = 2'b10;
    end
    

  // forwarded values
  wire [31:0] forwardA_exmem = EX_MEM_ALUOut;
  wire [31:0] forwardA_memwb  = (MEM_WB_type == LOAD) ? MEM_WB_LMD : MEM_WB_ALUOut;
  wire [31:0] forwardB_exmem = EX_MEM_ALUOut;
  wire [31:0] forwardB_memwb  = (MEM_WB_type == LOAD) ? MEM_WB_LMD : MEM_WB_ALUOut;

  wire [31:0] alu_in_A = (forwardA_sel == 2'b01) ? forwardA_exmem :
                         (forwardA_sel == 2'b10) ? forwardA_memwb : ID_EX_A;
  wire [31:0] alu_in_B_presel = (forwardB_sel == 2'b01) ? forwardB_exmem :
                                (forwardB_sel == 2'b10) ? forwardB_memwb : ID_EX_B;
  wire [31:0] alu_in_B = (ID_EX_type == RM_ALU || ID_EX_type == LOAD || ID_EX_type == STORE) ? ID_EX_Imm : alu_in_B_presel;

  // EX stage sequential
  always @(posedge clk) begin
    if (reset) begin
      EX_MEM_type <= NOP_T;
      EX_MEM_IR <= 32'b0;
      EX_MEM_ALUOut <= 32'b0;
      EX_MEM_B <= 32'b0;
      EX_MEM_cond <= 1'b0;
    end else begin
      if (HALTED) begin
        EX_MEM_type <= HALT;
        EX_MEM_IR <= 32'b0;
      end else begin
        EX_MEM_type <= ID_EX_type;
        EX_MEM_IR <= ID_EX_IR;
        case (ID_EX_type)
          RR_ALU: begin
            case (ID_EX_IR[31:26])
              ADD: EX_MEM_ALUOut <= alu_in_A + alu_in_B_presel;
              SUB: EX_MEM_ALUOut <= alu_in_A - alu_in_B_presel;
              ANDI: EX_MEM_ALUOut <= alu_in_A & alu_in_B_presel;
              OR:  EX_MEM_ALUOut <= alu_in_A | alu_in_B_presel;
              SLT: EX_MEM_ALUOut <= (alu_in_A < alu_in_B_presel) ? 32'b1 : 32'b0;
              MUL: EX_MEM_ALUOut <= alu_in_A * alu_in_B_presel;
              default: EX_MEM_ALUOut <= 32'b0;
            endcase
            EX_MEM_B <= alu_in_B_presel;
          end
          RM_ALU: begin
            case (ID_EX_IR[31:26])
              ADDI: EX_MEM_ALUOut <= alu_in_A + ID_EX_Imm;
              SUBI: EX_MEM_ALUOut <= alu_in_A - ID_EX_Imm;
              SLTI: EX_MEM_ALUOut <= (alu_in_A < ID_EX_Imm) ? 32'b1 : 32'b0;
              default: EX_MEM_ALUOut <= 32'b0;
            endcase
            EX_MEM_B <= ID_EX_B;
          end
          LOAD, STORE: begin
            EX_MEM_ALUOut <= alu_in_A + ID_EX_Imm; // address
            EX_MEM_B <= alu_in_B_presel;
          end
          BRANCH: begin
            EX_MEM_ALUOut <= ID_EX_NPC + ID_EX_Imm;
            EX_MEM_cond <= (ID_EX_A == 0);
          end
          default: begin
            EX_MEM_ALUOut <= 32'b0;
            EX_MEM_B <= 32'b0;
          end
        endcase
      end
    end
  end

  // MEM stage sequential
  always @(posedge clk) begin
    if (reset) begin
      MEM_WB_type <= NOP_T;
      MEM_WB_IR <= 32'b0;
      MEM_WB_ALUOut <= 32'b0;
      MEM_WB_LMD <= 32'b0;
      branch_taken <= 0;
      branch_target <= 0;
    end else begin
      if (HALTED) begin
        MEM_WB_type <= HALT;
        MEM_WB_IR <= 32'b0;
      end else begin
        MEM_WB_type <= EX_MEM_type;
        MEM_WB_IR <= EX_MEM_IR;
        case (EX_MEM_type)
          RR_ALU, RM_ALU: begin
            MEM_WB_ALUOut <= EX_MEM_ALUOut;
          end
          LOAD: begin
            MEM_WB_LMD <= Mem[EX_MEM_ALUOut];
          end
          STORE: begin
            if (!branch_taken) begin
              Mem[EX_MEM_ALUOut] <= EX_MEM_B;
            end
          end
          BRANCH: begin
            if ( (EX_MEM_IR[31:26] == BEQZ && EX_MEM_cond == 1) ||
                 (EX_MEM_IR[31:26] == BNEQZ && EX_MEM_cond == 0) ) begin
              branch_taken <= 1;
              branch_target <= EX_MEM_ALUOut;
            end else begin
              branch_taken <= 0;
            end
          end
          default: begin
            // NOP / HALT
          end
        endcase
      end
    end
  end

  // WB stage sequential
  always @(posedge clk) begin
    if (reset) begin
      HALTED <= 0;
    end else begin
      if (MEM_WB_type == RR_ALU) begin
        RegFile[MEM_WB_IR[15:11]] <= MEM_WB_ALUOut;
      end else if (MEM_WB_type == RM_ALU) begin
        RegFile[MEM_WB_IR[20:16]] <= MEM_WB_ALUOut;
      end else if (MEM_WB_type == LOAD) begin
        RegFile[MEM_WB_IR[20:16]] <= MEM_WB_LMD;
      end else if (MEM_WB_type == HALT) begin
        HALTED <= 1;
      end
    end
  end

endmodule
