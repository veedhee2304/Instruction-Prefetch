// pipeline_with_prefetch.v
// 5-stage pipeline with prefetch FIFO + prefetch engine (design file)
// Cleaned and fixed for Vivado syntax issues.

`timescale 1ns/1ps

// -------------------------
// simple_imem: synchronous memory with request/response handshake and latency
// -------------------------
module simple_imem #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 32,
    parameter DEPTH = (1<<10),
    parameter LATENCY = 3
)(
    input clk,
    input rst_n,
    // request
    input                   req_valid,
    input  [ADDR_WIDTH-1:0] req_addr,
    output                  req_ready,
    // response
    output                  rsp_valid,
    output [DATA_WIDTH-1:0] rsp_data
);
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    // pipeline for latency
    reg [LATENCY-1:0]   valid_pipe;
    reg [ADDR_WIDTH-1:0]  addr_pipe [0:LATENCY-1];
    integer i;

    assign req_ready = 1'b1; // always accept request

    always @(posedge clk) begin
        if (!rst_n) begin
            valid_pipe <= {LATENCY{1'b0}};
            for (i=0;i<LATENCY;i=i+1) addr_pipe[i] <= {ADDR_WIDTH{1'b0}};
        end else begin
            valid_pipe <= {valid_pipe[LATENCY-2:0], req_valid};
            if (req_valid) addr_pipe[LATENCY-1] <= req_addr;
        end
    end

    assign rsp_valid = valid_pipe[LATENCY-1];
    assign rsp_data  = (valid_pipe[LATENCY-1]) ? mem[addr_pipe[LATENCY-1]] : {DATA_WIDTH{1'b0}};

    // allow testbench to initialize mem (hierarchical access)
endmodule


// -------------------------
// prefetch_fifo: proper pop & push handshakes, flush support
// -------------------------
module prefetch_fifo #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 8,
    parameter PTR_WIDTH = 3 // must satisfy 2**PTR_WIDTH == DEPTH
)(
    input                   clk,
    input                   rst_n,
    // write side (prefetch engine writes when w_valid & w_ready)
    input                   w_valid,
    input  [DATA_WIDTH-1:0] w_data,
    output                  w_ready,
    // read side (IF pops with r_pop; r_valid indicates data available)
    input                   r_pop,
    output                  r_valid,
    output [DATA_WIDTH-1:0] r_data,
    // status
    output [PTR_WIDTH:0]    occupancy,
    // flush
    input                   flush
);
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [PTR_WIDTH-1:0] wptr, rptr;
    reg [PTR_WIDTH:0] occ;
    integer i;
    assign w_ready = (occ < DEPTH);
    assign r_valid = (occ > 0);
    assign r_data  = mem[rptr];
    assign occupancy = occ;

    always @(posedge clk) begin
        if (!rst_n || flush) begin
            wptr <= {PTR_WIDTH{1'b0}};
            rptr <= {PTR_WIDTH{1'b0}};
            occ  <= {PTR_WIDTH+1{1'b0}};
        end else begin
            // write
            if (w_valid && w_ready) begin
                mem[wptr] <= w_data;
                wptr <= wptr + 1'b1;
                occ <= occ + 1'b1;
            end
            // pop (read)
            if (r_pop && (occ > 0)) begin
                rptr <= rptr + 1'b1;
                occ <= occ - 1'b1;
            end
        end
    end
endmodule


// -------------------------
// prefetch_engine: single-issue engine that issues imem requests while FIFO has room
// -------------------------
module prefetch_engine #(
    parameter ADDR_WIDTH = 10
)(
    input clk,
    input rst_n,
    input [ADDR_WIDTH-1:0] start_pc,
    input start_valid,
    input [7:0] fifo_room, // free slots in FIFO
    input flush,
    // imem interface
    output reg imem_req_valid,
    output reg [ADDR_WIDTH-1:0] imem_req_addr,
    input imem_req_ready
);
    reg running;
    reg [ADDR_WIDTH-1:0] cur_pc;

    always @(posedge clk) begin
        if (!rst_n) begin
            running <= 1'b0;
            cur_pc <= {ADDR_WIDTH{1'b0}};
            imem_req_valid <= 1'b0;
            imem_req_addr <= {ADDR_WIDTH{1'b0}};
        end else begin
            if (flush) begin
                running <= 1'b0;
                imem_req_valid <= 1'b0;
            end else begin
                if (!running && start_valid) begin
                    running <= 1'b1;
                    cur_pc <= start_pc;
                end
                if (running) begin
                    if (fifo_room > 0) begin
                        imem_req_valid <= 1'b1;
                        imem_req_addr <= cur_pc;
                        if (imem_req_ready) begin
                            cur_pc <= cur_pc + 1'b1;
                        end
                    end else begin
                        imem_req_valid <= 1'b0;
                    end
                end
            end
        end
    end
endmodule


// -------------------------
// register file (32 x 32)
// -------------------------
module regfile (
    input clk,
    input rst_n,
    input we,
    input [4:0] waddr,
    input [31:0] wdata,
    input [4:0] raddr1,
    input [4:0] raddr2,
    output [31:0] rdata1,
    output [31:0] rdata2
);
    reg [31:0] rf [0:31];
    integer i;
    assign rdata1 = (raddr1 == 5'd0) ? 32'd0 : rf[raddr1];
    assign rdata2 = (raddr2 == 5'd0) ? 32'd0 : rf[raddr2];

    always @(posedge clk) begin
        if (!rst_n) begin
            for (i=0;i<32;i=i+1) rf[i] <= 32'd0;
        end else begin
            if (we && (waddr != 5'd0)) rf[waddr] <= wdata;
        end
    end
endmodule


// -------------------------
// forwarding_unit and hazard_unit (load-use)
// -------------------------
module forwarding_unit(
    input [4:0] ex_rs, ex_rt,
    input [4:0] exmem_rd,
    input exmem_regwrite,
    input [4:0] memwb_rd,
    input memwb_regwrite,
    output reg [1:0] fwdA,
    output reg [1:0] fwdB
);
    always @(*) begin
        fwdA = 2'b00;
        fwdB = 2'b00;
        if (exmem_regwrite && (exmem_rd != 0) && (exmem_rd == ex_rs))
            fwdA = 2'b10;
        else if (memwb_regwrite && (memwb_rd != 0) && (memwb_rd == ex_rs))
            fwdA = 2'b01;

        if (exmem_regwrite && (exmem_rd != 0) && (exmem_rd == ex_rt))
            fwdB = 2'b10;
        else if (memwb_regwrite && (memwb_rd != 0) && (memwb_rd == ex_rt))
            fwdB = 2'b01;
    end
endmodule

module hazard_unit(
    input id_ex_memread,
    input [4:0] id_ex_rt,
    input [4:0] if_id_rs,
    input [4:0] if_id_rt,
    output reg pc_write,
    output reg if_id_write,
    output reg stall
);
    always @(*) begin
        if (id_ex_memread && ((id_ex_rt == if_id_rs) || (id_ex_rt == if_id_rt))) begin
            pc_write = 1'b0;
            if_id_write = 1'b0;
            stall = 1'b1;
        end else begin
            pc_write = 1'b1;
            if_id_write = 1'b1;
            stall = 1'b0;
        end
    end
endmodule


// -------------------------
// data memory (for lw/sw) - sync read/write (read after one cycle)
// -------------------------
module data_mem #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 32,
    parameter DEPTH = (1<<10)
)(
    input clk,
    input rst_n,
    input en,
    input we,
    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] wdata,
    output reg [DATA_WIDTH-1:0] rdata
);
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    integer i;
    always @(posedge clk) begin
        if (!rst_n) begin
            for (i=0;i<DEPTH;i=i+1) mem[i] <= 32'd0;
            rdata <= 32'd0;
        end else begin
            if (en) begin
                if (we) mem[addr] <= wdata;
                rdata <= mem[addr];
            end
        end
    end
endmodule


// -------------------------
// Top-level pipeline_core
// -------------------------
module pipeline_core #(
    parameter ADDR_WIDTH = 10,
    parameter PF_DEPTH = 8
)(
    input clk,
    input rst_n,
    // debug outputs
    output [31:0] dbg_if_insn,
    output [31:0] dbg_pc,
    output [7:0] dbg_pf_occ,
    output [31:0] dbg_reg1
);
    // Instruction encoding constants (MIPS-like)
    localparam OPC_RTYPE = 6'b000000;
    localparam OPC_LW    = 6'b100011;
    localparam OPC_SW    = 6'b101011;
    localparam OPC_BEQ   = 6'b000100;
    localparam OPC_ADDI  = 6'b001000;
    localparam FUNCT_ADD = 6'b100000;
    localparam FUNCT_SUB = 6'b100010;

    // IMEM instance
    wire imem_req_valid;
    wire [ADDR_WIDTH-1:0] imem_req_addr;
    wire imem_req_ready;
    wire imem_rsp_valid;
    wire [31:0] imem_rsp_data;

    simple_imem #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(32), .DEPTH(1<<ADDR_WIDTH), .LATENCY(3)) imem (
        .clk(clk),
        .rst_n(rst_n),
        .req_valid(imem_req_valid),
        .req_addr(imem_req_addr),
        .req_ready(imem_req_ready),
        .rsp_valid(imem_rsp_valid),
        .rsp_data(imem_rsp_data)
    );

    // Prefetch FIFO
    wire pf_w_ready;
    reg pf_w_valid;
    wire [31:0] pf_w_data = imem_rsp_data;
    wire pf_r_valid;
    wire [31:0] pf_r_data;
    reg pf_r_pop;
    // determine occupancy width from PF_DEPTH
    localparam OCC_WIDTH = $clog2(PF_DEPTH) + 1;
    wire [OCC_WIDTH-1:0] pf_occupancy;
    reg pf_flush;

    prefetch_fifo #(.DATA_WIDTH(32), .DEPTH(PF_DEPTH), .PTR_WIDTH($clog2(PF_DEPTH))) instr_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .w_valid(imem_rsp_valid),
        .w_data(imem_rsp_data),
        .w_ready(pf_w_ready),
        .r_pop(pf_r_pop),
        .r_valid(pf_r_valid),
        .r_data(pf_r_data),
        .occupancy(pf_occupancy),
        .flush(pf_flush)
    );

    // Prefetch engine
    reg pstart_valid;
    wire [ADDR_WIDTH-1:0] pstart_pc;
    reg [ADDR_WIDTH-1:0] pstart_pc_reg;
    assign pstart_pc = pstart_pc_reg;

    prefetch_engine #(.ADDR_WIDTH(ADDR_WIDTH)) pengine (
        .clk(clk),
        .rst_n(rst_n),
        .start_pc(pstart_pc),
        .start_valid(pstart_valid),
        .fifo_room((PF_DEPTH - pf_occupancy)),
        .flush(pf_flush),
        .imem_req_valid(imem_req_valid),
        .imem_req_addr(imem_req_addr),
        .imem_req_ready(imem_req_ready)
    );

    // Data memory
    wire [31:0] dmem_rdata;
    reg dmem_en, dmem_we;
    reg [ADDR_WIDTH-1:0] dmem_addr;
    reg [31:0] dmem_wdata;
    data_mem #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(32), .DEPTH(1<<ADDR_WIDTH)) dmem (
        .clk(clk),
        .rst_n(rst_n),
        .en(dmem_en),
        .we(dmem_we),
        .addr(dmem_addr),
        .wdata(dmem_wdata),
        .rdata(dmem_rdata)
    );

    // Program counter
    reg [ADDR_WIDTH-1:0] pc, next_pc;

    // IF stage
    reg if_valid;
    reg [31:0] if_insn;
    reg [ADDR_WIDTH-1:0] if_pc;

    // IF/ID regs
    reg if_id_valid;
    reg [31:0] if_id_insn;
    reg [ADDR_WIDTH-1:0] if_id_pc;

    // ID/EX regs
    reg id_ex_valid;
    reg [31:0] id_ex_reg_rs_val, id_ex_reg_rt_val;
    reg [4:0] id_ex_rs, id_ex_rt, id_ex_rd;
    reg [31:0] id_ex_imm;
    reg id_ex_memread, id_ex_memwrite, id_ex_regwrite;
    reg [5:0] id_ex_opcode;
    reg [5:0] id_ex_funct;

    // EX/MEM regs
    reg ex_mem_valid;
    reg [31:0] ex_mem_alu;
    reg [31:0] ex_mem_wval;
    reg [4:0] ex_mem_rd;
    reg ex_mem_memread, ex_mem_memwrite, ex_mem_regwrite;

    // MEM/WB regs
    reg mem_wb_valid;
    reg [31:0] mem_wb_rdata;
    reg [31:0] mem_wb_alu;
    reg [4:0] mem_wb_rd;
    reg mem_wb_regwrite;

    // Register file
    wire [31:0] rf_rdata1, rf_rdata2;
    regfile rf (
        .clk(clk),
        .rst_n(rst_n),
        .we(mem_wb_regwrite),
        .waddr(mem_wb_rd),
        .wdata(mem_wb_regwrite ? (mem_wb_rdata) : mem_wb_alu),
        .raddr1(if_id_insn[25:21]),
        .raddr2(if_id_insn[20:16]),
        .rdata1(rf_rdata1),
        .rdata2(rf_rdata2)
    );

    // forwarding & hazard
    wire [1:0] forwardA, forwardB;
    forwarding_unit fu (
        .ex_rs(id_ex_rs),
        .ex_rt(id_ex_rt),
        .exmem_rd(ex_mem_rd),
        .exmem_regwrite(ex_mem_regwrite),
        .memwb_rd(mem_wb_rd),
        .memwb_regwrite(mem_wb_regwrite),
        .fwdA(forwardA),
        .fwdB(forwardB)
    );

    wire hz_pc_write, hz_if_id_write, hz_stall;
    hazard_unit hu (
        .id_ex_memread(id_ex_memread),
        .id_ex_rt(id_ex_rt),
        .if_id_rs(if_id_insn[25:21]),
        .if_id_rt(if_id_insn[20:16]),
        .pc_write(hz_pc_write),
        .if_id_write(hz_if_id_write),
        .stall(hz_stall)
    );

    // expose debug
    assign dbg_if_insn = if_insn;
    // simplified: expose pc directly (avoid slicing-concatenation issues)
    assign dbg_pc = pc;
    // widen occupancy to 8-bit output (zero-extend)
    assign dbg_pf_occ = {{(8-OCC_WIDTH){1'b0}}, pf_occupancy};
    assign dbg_reg1 = rf_rdata1;

    // -------------------------
    // IF stage: pop from prefetch FIFO when IF can accept
    // -------------------------
    always @(posedge clk) begin
        if (!rst_n) begin
            pc <= {ADDR_WIDTH{1'b0}};
            pstart_valid <= 1'b0;
            pstart_pc_reg <= {ADDR_WIDTH{1'b0}};
            pf_flush <= 1'b0;
            if_valid <= 1'b0;
            if_insn <= 32'd0;
            if_pc <= {ADDR_WIDTH{1'b0}};
            pf_r_pop <= 1'b0;
        end else begin
            // start prefetch engine once at reset release
            if (pstart_valid) begin
                pstart_valid <= 1'b0;
            end

            // default: no flush
            pf_flush <= 1'b0;

            // when FIFO has instruction and we are allowed to update IF/PC (hz_pc_write), pop and take it
            if (pf_r_valid && hz_pc_write) begin
                // pop instruction
                pf_r_pop <= 1'b1;
                if_valid <= 1'b1;
                if_insn <= pf_r_data;
                if_pc <= pc;
                pc <= pc + 1'b1;
            end else begin
                pf_r_pop <= 1'b0;
                if_valid <= 1'b0;
            end
        end
    end

    // IF/ID register (with hazard stall support)
    always @(posedge clk) begin
        if (!rst_n) begin
            if_id_valid <= 1'b0;
            if_id_insn <= 32'd0;
            if_id_pc <= {ADDR_WIDTH{1'b0}};
        end else begin
            if (hz_if_id_write) begin
                if_id_valid <= if_valid;
                if_id_insn <= if_insn;
                if_id_pc <= if_pc;
            end else begin
                // stall: keep old IF/ID
                if_id_valid <= if_id_valid;
            end
        end
    end

    // ID stage: decode
    wire [5:0] id_opcode = if_id_insn[31:26];
    wire [5:0] id_funct  = if_id_insn[5:0];
    wire [4:0] id_rs = if_id_insn[25:21];
    wire [4:0] id_rt = if_id_insn[20:16];
    wire [4:0] id_rd = if_id_insn[15:11];
    wire [15:0] id_imm = if_id_insn[15:0];
    reg branch_taken;
    reg [ADDR_WIDTH-1:0] branch_target;

    // sign-extend immediate as full 32-bit value and a sliced version for branch target math
    wire [31:0] id_imm_ext_full = {{16{id_imm[15]}}, id_imm};
    wire [ADDR_WIDTH-1:0] id_imm_ext_pc = id_imm_ext_full[ADDR_WIDTH-1:0];

    // ID -> EX pipeline
    always @(posedge clk) begin
        if (!rst_n) begin
            id_ex_valid <= 1'b0;
            id_ex_memread <= 1'b0;
            id_ex_memwrite <= 1'b0;
            id_ex_regwrite <= 1'b0;
            id_ex_opcode <= 6'd0;
            id_ex_funct <= 6'd0;
            id_ex_rs <= 5'd0;
            id_ex_rt <= 5'd0;
            id_ex_rd <= 5'd0;
            id_ex_reg_rs_val <= 32'd0;
            id_ex_reg_rt_val <= 32'd0;
            id_ex_imm <= 32'd0;
        end else begin
            if (hz_stall) begin
                // insert bubble
                id_ex_valid <= 1'b0;
                id_ex_memread <= 1'b0;
                id_ex_memwrite <= 1'b0;
                id_ex_regwrite <= 1'b0;
            end else begin
                id_ex_valid <= if_id_valid;
                id_ex_opcode <= id_opcode;
                id_ex_funct <= id_funct;
                id_ex_rs <= id_rs;
                id_ex_rt <= id_rt;
                id_ex_rd <= id_rd;
                id_ex_reg_rs_val <= rf_rdata1;
                id_ex_reg_rt_val <= rf_rdata2;
                id_ex_imm <= id_imm_ext_full;
                id_ex_memread <= (id_opcode == OPC_LW);
                id_ex_memwrite <= (id_opcode == OPC_SW);
                id_ex_regwrite <= ((id_opcode == OPC_RTYPE) || (id_opcode == OPC_LW) || (id_opcode == OPC_ADDI));
            end

            // branch evaluation in ID (simple BEQ) - if taken, update PC, flush fifo and IF/ID
            branch_taken <= 1'b0;
            if (if_id_valid && id_opcode == OPC_BEQ) begin
                if (rf_rdata1 == rf_rdata2) begin
                    // compute branch target (PC relative immediate * 1 word)
                    branch_target <= if_id_pc + 1 + id_imm_ext_pc;
                    branch_taken <= 1'b1;
                end
            end

            // if branch taken, perform flush/pc update and restart prefetch
            if (branch_taken) begin
                pc <= branch_target;
                pf_flush <= 1'b1;
                // restart prefetch at branch_target
                pstart_pc_reg <= branch_target;
                pstart_valid <= 1'b1;
            end
        end
    end

    // EX stage: ALU with forwarding
    reg [31:0] ex_op_a, ex_op_b;
    reg [31:0] ex_alu_result;
    always @(*) begin
        // default sources from id_ex_reg_*
        ex_op_a = id_ex_reg_rs_val;
        ex_op_b = id_ex_reg_rt_val;
        // forwarding A
        if (forwardA == 2'b10) ex_op_a = ex_mem_alu;
        else if (forwardA == 2'b01) ex_op_a = (mem_wb_regwrite ? mem_wb_rdata : mem_wb_alu);
        // forwarding B
        if (forwardB == 2'b10) ex_op_b = ex_mem_alu;
        else if (forwardB == 2'b01) ex_op_b = (mem_wb_regwrite ? mem_wb_rdata : mem_wb_alu);

        // if instruction is addi, use imm as second operand
        if (id_ex_opcode == OPC_ADDI) ex_op_b = id_ex_imm;
        // for lw/sw use imm as offset (base in op_a)
        if (id_ex_opcode == OPC_LW || id_ex_opcode == OPC_SW) begin
            ex_op_b = id_ex_imm; // will compute address = base + imm
        end
    end

    always @(*) begin
        ex_alu_result = 32'd0;
        if (id_ex_opcode == OPC_RTYPE) begin
            case (id_ex_funct)
                FUNCT_ADD: ex_alu_result = ex_op_a + ex_op_b;
                FUNCT_SUB: ex_alu_result = ex_op_a - ex_op_b;
                default: ex_alu_result = ex_op_a + ex_op_b;
            endcase
        end else if (id_ex_opcode == OPC_ADDI) begin
            ex_alu_result = ex_op_a + ex_op_b;
        end else if (id_ex_opcode == OPC_LW || id_ex_opcode == OPC_SW) begin
            ex_alu_result = ex_op_a + ex_op_b; // address
        end else begin
            ex_alu_result = 32'd0;
        end
    end

    // EX -> MEM pipeline register
    always @(posedge clk) begin
        if (!rst_n) begin
            ex_mem_valid <= 1'b0;
            ex_mem_alu <= 32'd0;
            ex_mem_wval <= 32'd0;
            ex_mem_rd <= 5'd0;
            ex_mem_memread <= 1'b0;
            ex_mem_memwrite <= 1'b0;
            ex_mem_regwrite <= 1'b0;
        end else begin
            ex_mem_valid <= id_ex_valid;
            ex_mem_alu <= ex_alu_result;
            ex_mem_wval <= id_ex_reg_rt_val;
            // destination reg selection: for R-type it's rd, for addi/lw it's rt
            if (id_ex_opcode == OPC_RTYPE) ex_mem_rd <= id_ex_rd;
            else ex_mem_rd <= id_ex_rt;
            ex_mem_memread <= id_ex_memread;
            ex_mem_memwrite <= id_ex_memwrite;
            ex_mem_regwrite <= id_ex_regwrite;
        end
    end

    // MEM stage: access data memory
    always @(posedge clk) begin
        if (!rst_n) begin
            mem_wb_valid <= 1'b0;
            mem_wb_rdata <= 32'd0;
            mem_wb_alu <= 32'd0;
            mem_wb_rd <= 5'd0;
            mem_wb_regwrite <= 1'b0;
            // disable dmem
            dmem_en <= 1'b0;
            dmem_we <= 1'b0;
            dmem_addr <= {ADDR_WIDTH{1'b0}};
            dmem_wdata <= 32'd0;
        end else begin
            // drive dmem for one cycle when ex_mem_valid is asserted
            if (ex_mem_valid && ex_mem_memwrite) begin
                dmem_en <= 1'b1;
                dmem_we <= 1'b1;
                dmem_addr <= ex_mem_alu[ADDR_WIDTH-1:0];
                dmem_wdata <= ex_mem_wval;
            end else if (ex_mem_valid && ex_mem_memread) begin
                dmem_en <= 1'b1;
                dmem_we <= 1'b0;
                dmem_addr <= ex_mem_alu[ADDR_WIDTH-1:0];
            end else begin
                dmem_en <= 1'b0;
                dmem_we <= 1'b0;
            end

            // capture outputs into MEM/WB
            mem_wb_valid <= ex_mem_valid;
            mem_wb_alu <= ex_mem_alu;
            mem_wb_rdata <= dmem_rdata;
            mem_wb_rd <= ex_mem_rd;
            mem_wb_regwrite <= ex_mem_regwrite;
        end
    end

    // After reset, pulse pstart_valid to start prefetch at PC=0
    reg pstart_pulse_done;
    always @(posedge clk) begin
        if (!rst_n) begin
            pstart_valid <= 1'b0;
            pstart_pc_reg <= {ADDR_WIDTH{1'b0}};
            pstart_pulse_done <= 1'b0;
        end else begin
            if (!pstart_pulse_done) begin
                pstart_pc_reg <= {ADDR_WIDTH{1'b0}};
                pstart_valid <= 1'b1;
                pstart_pulse_done <= 1'b1;
            end else pstart_valid <= 1'b0;
        end
    end

endmodule
