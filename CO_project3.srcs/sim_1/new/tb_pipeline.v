`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 09:17:03 PM
// Design Name: 
// Module Name: tb_pipeline
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 08:36:46 PM
// Design Name: 
// Module Name: tb_pipe_prefetch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//-------------------------
// Testbench
// -------------------------
module tb_pipeline;

    reg clk, rst_n;
    wire [31:0] dbg_if_insn;
    wire [31:0] dbg_pc;
    wire [7:0] dbg_pf_occ;
    wire [31:0] dbg_r1;

    integer i;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    initial begin
        rst_n = 0;
        #150 rst_n = 1;
    end
    pipeline_core #(.ADDR_WIDTH(10), .PF_DEPTH(8)) core (
        .clk(clk),
        .rst_n(rst_n),
        .dbg_if_insn(dbg_if_insn),
        .dbg_pc(dbg_pc),
        .dbg_pf_occ(dbg_pf_occ),
        .dbg_reg1(dbg_r1)
    );

    // ===== Helper instruction generators =====
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

    // ===== Program + data memory initialization =====
    initial begin
        // Clear IMEM
        for (i = 0; i < 1024; i = i + 1)
            tb_pipeline.core.imem.mem[i] = 32'h00000000;

        // Program
        tb_pipeline.core.imem.mem[0]  = ITYPE(6'b001000, 5'd1, 5'd0, 16'd10); // addi $1,$0,10
        tb_pipeline.core.imem.mem[1]  = ITYPE(6'b001000, 5'd2, 5'd0, 16'd20); // addi $2,$0,20
        tb_pipeline.core.imem.mem[2]  = ITYPE(6'b101011, 5'd2, 5'd0, 16'd4);  // sw   $2,4($0)
        tb_pipeline.core.imem.mem[3]  = ITYPE(6'b100011, 5'd3, 5'd0, 16'd4);  // lw   $3,4($0)
        tb_pipeline.core.imem.mem[4]  = RTYPE(6'b100000, 5'd4, 5'd1, 5'd3);   // add  $4,$1,$3
        tb_pipeline.core.imem.mem[5]  = ITYPE(6'b001000, 5'd5, 5'd0, 16'd0);  // addi $5,$0,0
        tb_pipeline.core.imem.mem[6]  = ITYPE(6'b000100, 5'd4, 5'd5, 16'd2);  // beq  $4,$5,2
        tb_pipeline.core.imem.mem[7]  = RTYPE(6'b100010, 5'd6, 5'd4, 5'd1);   // sub  $6,$4,$1
        tb_pipeline.core.imem.mem[8]  = ITYPE(6'b001000, 5'd7, 5'd7, 16'd1);  // addi $7,$7,1
        tb_pipeline.core.imem.mem[9]  = ITYPE(6'b001000, 5'd7, 5'd7, 16'd1);  
        tb_pipeline.core.imem.mem[10] = ITYPE(6'b001000, 5'd7, 5'd7, 16'd1);

        // Clear DMEM
        for (i = 0; i < 1024; i = i + 1)
            tb_pipeline.core.dmem.mem[i] = 32'h00000000;

        // Print header
        $display("Starting simulation...");
        $display("Time\tPC\tPF_occ\tIF_Insn\tR1");
        
        #200;

        // Print cycles (NO declarations inside repeat block!)
        for (i = 0; i < 300; i = i + 1) begin
            #10;
            $display("%0t\t%0d\t%0d\t%h\t%0d",
                $time, dbg_pc, dbg_pf_occ, dbg_if_insn, dbg_r1);
        end

        $display("End simulation.");
        #20 $finish;
    end

endmodule



//module tb_load_use_test;

//    reg clk, rst_n;
//    wire [31:0] dbg_pc, dbg_if_insn, dbg_r1;
//    wire [7:0] dbg_pf_occ;

//    pipeline_core core (
//        .clk(clk),
//        .rst_n(rst_n),
//        .dbg_if_insn(dbg_if_insn),
//        .dbg_pc(dbg_pc),
//        .dbg_pf_occ(dbg_pf_occ),
//        .dbg_reg1(dbg_r1)
//    );

//    integer i;

//    initial begin clk=0; forever #5 clk=~clk; end
//    initial begin rst_n=0; #50 rst_n=1; end

//    function [31:0] I; input [5:0] op; input [4:0] rt,rs; input [15:0] imm;
//    begin I={op,rs,rt,imm}; end endfunction
//    function [31:0] R; input [5:0] fn; input [4:0] rd,rs,rt;
//    begin R={6'b000000,rs,rt,rd,5'd0,fn}; end endfunction

//    initial begin
//        // Clear IMEM + DMEM
//        for(i=0;i<1024;i=i+1) begin
//            core.imem.mem[i]=32'h0;
//            core.dmem.mem[i]=32'h0;
//        end

//        // preload DMEM
//        core.dmem.mem[0] = 32'h0000000A;  // 10
//        core.dmem.mem[1] = 32'h00000014;  // 20

//        core.imem.mem[0] = I(6'b100011,5'd1,5'd0,16'd0);  // lw $1,0($0)
//        core.imem.mem[1] = R(6'b100000,5'd2,5'd1,5'd1);   // add $2,$1,$1   <-- stall expected
//        core.imem.mem[2] = I(6'b001000,5'd3,5'd2,16'd5);  // addi $3,$2,5
//        core.imem.mem[3] = I(6'b100011,5'd4,5'd0,16'd4);  // lw $4,4($0)
//        core.imem.mem[4] = R(6'b100010,5'd5,5'd4,5'd2);   // sub $5,$4,$2

//        #200;

//        repeat(150) begin
//            #10;
//            $display("%0t PC=%0d IF=%h PF=%0d R1=%0d",
//                $time, dbg_pc, dbg_if_insn, dbg_pf_occ, dbg_r1);
//        end

//        $finish;
//    end
// endmodule
//module tb_fifo_saturation;

//    reg clk, rst_n;
//    wire [31:0] dbg_pc, dbg_if_insn, dbg_r1;
//    wire [7:0] dbg_pf_occ;

//    pipeline_core core (
//        .clk(clk),
//        .rst_n(rst_n),
//        .dbg_if_insn(dbg_if_insn),
//        .dbg_pc(dbg_pc),
//        .dbg_pf_occ(dbg_pf_occ),
//        .dbg_reg1(dbg_r1)
//    );

//    integer i;

//    initial begin clk=0; forever #5 clk=~clk; end
//    initial begin rst_n=0; #50 rst_n=1; end

//    function [31:0] I; input [5:0] op; input [4:0] rt,rs; input [15:0] imm;
//    begin I={op,rs,rt,imm}; end endfunction

//    initial begin
//        for(i=0;i<1024;i=i+1) core.imem.mem[i]=0;

//        // tight addi loop
//        for(i=0;i<32;i=i+1)
//            core.imem.mem[i] = I(6'b001000,5'd1,5'd1,16'd1);

//        core.imem.mem[32] = {6'b000010,       // J opcode
//                             26'd0 };         // jump to 0

//        #200;

//        repeat (200) begin
//            #10;
//            $display("%0t PC=%0d IF=%h PF_OCC=%0d R1=%0d",
//                $time, dbg_pc, dbg_if_insn, dbg_pf_occ, dbg_r1);
//        end

//        $finish;
//    end

//endmodule

//`timescale 1ns/1ps

//module tb_pipeline_mips;

//    reg clk;
//    reg rst_n;

//    // Debug outputs from pipeline
//    wire [31:0] dbg_pc;
//    wire [31:0] dbg_if_insn;
//    wire [7:0]  dbg_pf_occ;
//    wire [31:0] dbg_reg1;

//    // Instantiate DUT
//    pipeline_core #(.ADDR_WIDTH(10), .PF_DEPTH(8)) core (
//        .clk(clk),
//        .rst_n(rst_n),
//        .dbg_if_insn(dbg_if_insn),
//        .dbg_pc(dbg_pc),
//        .dbg_pf_occ(dbg_pf_occ),
//        .dbg_reg1(dbg_reg1)
//    );

//    // Clock generator
//    initial begin
//        clk = 0;
//        forever #5 clk = ~clk;
//    end

//    // Reset and IMEM initialization
//    integer i;
//    initial begin
//        rst_n = 0;

//        // Clear IMEM
//        for (i=0; i<1024; i=i+1)
//            core.imem.mem[i] = 32'h00000000;

//        // Load program
//        core.imem.mem[0]  = 32'h20080000;
//        core.imem.mem[1]  = 32'h20090001;
//        core.imem.mem[2]  = 32'h200A0002;
//        core.imem.mem[3]  = 32'h200B0000;

//        core.imem.mem[4]  = 32'h01094020;
//        core.imem.mem[5]  = 32'h012A4820;
//        core.imem.mem[6]  = 32'h01485020;
//        core.imem.mem[7]  = 32'h216B0001;

//        core.imem.mem[8]  = 32'h200C0032;
//        core.imem.mem[9]  = 32'h122C0003;

//        core.imem.mem[10] = 32'h1000FFFA;
//        core.imem.mem[11] = 32'h00000000;

//        core.imem.mem[12] = 32'h01096820;
//        core.imem.mem[13] = 32'h01AA6820;

//        // Release reset
//        #100 rst_n = 1;

//        $display("\n==== PIPELINE MIPS TEST START ====\n");
//        $display("Time\tPC\tPF_OCC\tInstruction");
//    end

//    // Monitor pipeline behavior
//    always @(posedge clk) begin
//        if (rst_n) begin
//            $display("%0t\t%0d\t%0d\t%h",
//                $time, dbg_pc, dbg_pf_occ, dbg_if_insn);
//        end
//    end

//    initial begin
//        // Run long enough for 50+ iterations
//        #20000;
//        $display("\n==== END OF SIMULATION ====\n");
//        $finish;
//    end

//endmodule



