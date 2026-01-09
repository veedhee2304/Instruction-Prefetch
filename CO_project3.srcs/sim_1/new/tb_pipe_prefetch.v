/ -------------------------
// Testbench
// -------------------------
module tb_pipeline;
    reg clk, rst_n;
    wire [31:0] dbg_if_insn;
    wire [31:0] dbg_pc;
    wire [7:0] dbg_pf_occ;
    wire [31:0] dbg_r1;

    initial begin
        clk = 0;
        rst_n = 0;
        #150 rst_n = 1;
    end
    always #5 clk = ~clk;

    pipeline_core #(.ADDR_WIDTH(10), .PF_DEPTH(8)) core (
        .clk(clk),
        .rst_n(rst_n),
        .dbg_if_insn(dbg_if_insn),
        .dbg_pc(dbg_pc),
        .dbg_pf_occ(dbg_pf_occ),
        .dbg_reg1(dbg_r1)
    );

    // Helper: assembler macros to create instructions
    function [31:0] RTYPE;
        input [5:0] funct;
        input [4:0] rd, rs, rt;
        begin
            RTYPE = {6'b000000, rs, rt, rd, 5'd0, funct};
        end
    endfunction

    function [31:0] ITYPE;
        input [5:0] opcode;
        input [4:0] rt, rs;
        input [15:0] imm;
        begin
            ITYPE = {opcode, rs, rt, imm};
        end
    endfunction

    // Initialize instruction memory in the imem instance
    initial begin
        integer i;
        // Fill IMEM with NOPs (addi $0, $0, 0)
        for (i=0;i<1024;i=i+1) begin
            tb_pipeline.core.imem.mem[i] = 32'h00000000;
        end

        // Program: basic load/store and arithmetic and branch
        // We'll use registers:
        // $1 = 10 (via addi)
        // $2 = 20 (via addi)
        // store $2 to mem[4]
        // load mem[4] -> $3
        // add $4 = $1 + $3
        // beq $4, $5, skip  (with $5 = 0, so won't branch)
        // sub $6 = $4 - $1
        // loop: addi $7, $7, 1  (increment $7) ; used to create some instruction stream
        // We'll put these instructions sequentially starting at address 0.

        // addi $1, $0, 10
        tb_pipeline.core.imem.mem[0] = ITYPE(6'b001000, 5'd1, 5'd0, 16'd10);
        // addi $2, $0, 20
        tb_pipeline.core.imem.mem[1] = ITYPE(6'b001000, 5'd2, 5'd0, 16'd20);
        // sw $2, 4($0)  -> store word at address 4
        tb_pipeline.core.imem.mem[2] = ITYPE(6'b101011, 5'd2, 5'd0, 16'd4);
        // lw $3, 4($0)
        tb_pipeline.core.imem.mem[3] = ITYPE(6'b100011, 5'd3, 5'd0, 16'd4);
        // add $4, $1, $3
        tb_pipeline.core.imem.mem[4] = RTYPE(6'b100000, 5'd4, 5'd1, 5'd3);
        // addi $5, $0, 0
        tb_pipeline.core.imem.mem[5] = ITYPE(6'b001000, 5'd5, 5'd0, 16'd0);
        // beq $4, $5, 2  (skip next two instructions if equal)
        tb_pipeline.core.imem.mem[6] = ITYPE(6'b000100, 5'd4, 5'd5, 16'd2);
        // sub $6, $4, $1
        tb_pipeline.core.imem.mem[7] = RTYPE(6'b100010, 5'd6, 5'd4, 5'd1);
        // addi $7, $7, 1
        tb_pipeline.core.imem.mem[8] = ITYPE(6'b001000, 5'd7, 5'd7, 16'd1);
        // addi $7, $7, 1
        tb_pipeline.core.imem.mem[9] = ITYPE(6'b001000, 5'd7, 5'd7, 16'd1);
        // addi $7, $7, 1
        tb_pipeline.core.imem.mem[10] = ITYPE(6'b001000, 5'd7, 5'd7, 16'd1);

        // Put some zeros further
        for (i=11;i<64;i=i+1) tb_pipeline.core.imem.mem[i] = 32'h00000000;

        // Initialize data memory (accessible via hierarchical path)
        for (i=0;i<1024;i=i+1) tb_pipeline.core.dmem.mem[i] = 32'h0;

        // show header
        $display("Starting simulation - pipeline with prefetch");
        $display("Time\tPC\tPF_occ\tIF_insn\tR1");
        #200;

        // print some cycles
        repeat (300) begin
            #10;
            $display("%0t\t%0d\t%0d\t%h\t%0d", $time, dbg_pc, dbg_pf_occ, dbg_if_insn, dbg_r1);
        end

        $display("End of test - finishing");
        #20 $finish;
    end
endmodule