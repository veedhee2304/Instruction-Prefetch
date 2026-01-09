// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Thu Nov 20 20:25:29 2025
// Host        : Veedhee running 64-bit major release  (build 9200)
// Command     : write_verilog -mode funcsim -nolib -force -file
//               C:/Users/DELL/CO_project3/CO_project3.sim/sim_1/synth/func/xsim/tb_pipeline_mips_func_synth.v
// Design      : top_pipeline
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module pipeline_core
   (Q,
    \pc_reg[9]__0_0 ,
    CLK,
    rst_n_IBUF);
  output [3:0]Q;
  output [9:0]\pc_reg[9]__0_0 ;
  input CLK;
  input rst_n_IBUF;

  wire CLK;
  wire [3:0]Q;
  wire if_valid;
  wire instr_fifo_n_5;
  wire instr_fifo_n_6;
  wire \pc_reg0_inferred__0/pc[0]__0_i_1_n_0 ;
  wire \pc_reg0_inferred__0/pc[1]__0_i_1_n_0 ;
  wire \pc_reg0_inferred__0/pc[2]__0_i_1_n_0 ;
  wire \pc_reg0_inferred__0/pc[3]__0_i_1_n_0 ;
  wire \pc_reg0_inferred__0/pc[4]__0_i_1_n_0 ;
  wire \pc_reg0_inferred__0/pc[5]__0_i_1_n_0 ;
  wire \pc_reg0_inferred__0/pc[6]__0_i_1_n_0 ;
  wire \pc_reg0_inferred__0/pc[7]__0_i_1_n_0 ;
  wire \pc_reg0_inferred__0/pc[8]__0_i_1_n_0 ;
  wire \pc_reg0_inferred__0/pc[9]__0_i_2_n_0 ;
  wire \pc_reg0_inferred__0/pc[9]__0_i_3_n_0 ;
  wire [9:0]\pc_reg[9]__0_0 ;
  wire pf_r_valid;
  wire rst_n_IBUF;

  FDRE #(
    .INIT(1'b0)) 
    if_valid_reg
       (.C(CLK),
        .CE(1'b1),
        .D(instr_fifo_n_6),
        .Q(if_valid),
        .R(1'b0));
  prefetch_fifo instr_fifo
       (.CLK(CLK),
        .E(pf_r_valid),
        .Q(Q),
        .SR(instr_fifo_n_5),
        .if_valid(if_valid),
        .\occ_reg[3]_0 (instr_fifo_n_6),
        .rst_n_IBUF(rst_n_IBUF));
  LUT1 #(
    .INIT(2'h1)) 
    \pc_reg0_inferred__0/pc[0]__0_i_1 
       (.I0(\pc_reg[9]__0_0 [0]),
        .O(\pc_reg0_inferred__0/pc[0]__0_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \pc_reg0_inferred__0/pc[1]__0_i_1 
       (.I0(\pc_reg[9]__0_0 [0]),
        .I1(\pc_reg[9]__0_0 [1]),
        .O(\pc_reg0_inferred__0/pc[1]__0_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \pc_reg0_inferred__0/pc[2]__0_i_1 
       (.I0(\pc_reg[9]__0_0 [0]),
        .I1(\pc_reg[9]__0_0 [1]),
        .I2(\pc_reg[9]__0_0 [2]),
        .O(\pc_reg0_inferred__0/pc[2]__0_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'h7F80)) 
    \pc_reg0_inferred__0/pc[3]__0_i_1 
       (.I0(\pc_reg[9]__0_0 [1]),
        .I1(\pc_reg[9]__0_0 [0]),
        .I2(\pc_reg[9]__0_0 [2]),
        .I3(\pc_reg[9]__0_0 [3]),
        .O(\pc_reg0_inferred__0/pc[3]__0_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \pc_reg0_inferred__0/pc[4]__0_i_1 
       (.I0(\pc_reg[9]__0_0 [2]),
        .I1(\pc_reg[9]__0_0 [0]),
        .I2(\pc_reg[9]__0_0 [1]),
        .I3(\pc_reg[9]__0_0 [3]),
        .I4(\pc_reg[9]__0_0 [4]),
        .O(\pc_reg0_inferred__0/pc[4]__0_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h7FFFFFFF80000000)) 
    \pc_reg0_inferred__0/pc[5]__0_i_1 
       (.I0(\pc_reg[9]__0_0 [3]),
        .I1(\pc_reg[9]__0_0 [1]),
        .I2(\pc_reg[9]__0_0 [0]),
        .I3(\pc_reg[9]__0_0 [2]),
        .I4(\pc_reg[9]__0_0 [4]),
        .I5(\pc_reg[9]__0_0 [5]),
        .O(\pc_reg0_inferred__0/pc[5]__0_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \pc_reg0_inferred__0/pc[6]__0_i_1 
       (.I0(\pc_reg0_inferred__0/pc[9]__0_i_3_n_0 ),
        .I1(\pc_reg[9]__0_0 [6]),
        .O(\pc_reg0_inferred__0/pc[6]__0_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \pc_reg0_inferred__0/pc[7]__0_i_1 
       (.I0(\pc_reg0_inferred__0/pc[9]__0_i_3_n_0 ),
        .I1(\pc_reg[9]__0_0 [6]),
        .I2(\pc_reg[9]__0_0 [7]),
        .O(\pc_reg0_inferred__0/pc[7]__0_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'h7F80)) 
    \pc_reg0_inferred__0/pc[8]__0_i_1 
       (.I0(\pc_reg[9]__0_0 [6]),
        .I1(\pc_reg0_inferred__0/pc[9]__0_i_3_n_0 ),
        .I2(\pc_reg[9]__0_0 [7]),
        .I3(\pc_reg[9]__0_0 [8]),
        .O(\pc_reg0_inferred__0/pc[8]__0_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \pc_reg0_inferred__0/pc[9]__0_i_2 
       (.I0(\pc_reg[9]__0_0 [7]),
        .I1(\pc_reg0_inferred__0/pc[9]__0_i_3_n_0 ),
        .I2(\pc_reg[9]__0_0 [6]),
        .I3(\pc_reg[9]__0_0 [8]),
        .I4(\pc_reg[9]__0_0 [9]),
        .O(\pc_reg0_inferred__0/pc[9]__0_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \pc_reg0_inferred__0/pc[9]__0_i_3 
       (.I0(\pc_reg[9]__0_0 [5]),
        .I1(\pc_reg[9]__0_0 [3]),
        .I2(\pc_reg[9]__0_0 [1]),
        .I3(\pc_reg[9]__0_0 [0]),
        .I4(\pc_reg[9]__0_0 [2]),
        .I5(\pc_reg[9]__0_0 [4]),
        .O(\pc_reg0_inferred__0/pc[9]__0_i_3_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \pc_reg[0]__0 
       (.C(CLK),
        .CE(pf_r_valid),
        .D(\pc_reg0_inferred__0/pc[0]__0_i_1_n_0 ),
        .Q(\pc_reg[9]__0_0 [0]),
        .R(instr_fifo_n_5));
  FDRE #(
    .INIT(1'b0)) 
    \pc_reg[1]__0 
       (.C(CLK),
        .CE(pf_r_valid),
        .D(\pc_reg0_inferred__0/pc[1]__0_i_1_n_0 ),
        .Q(\pc_reg[9]__0_0 [1]),
        .R(instr_fifo_n_5));
  FDRE #(
    .INIT(1'b0)) 
    \pc_reg[2]__0 
       (.C(CLK),
        .CE(pf_r_valid),
        .D(\pc_reg0_inferred__0/pc[2]__0_i_1_n_0 ),
        .Q(\pc_reg[9]__0_0 [2]),
        .R(instr_fifo_n_5));
  FDRE #(
    .INIT(1'b0)) 
    \pc_reg[3]__0 
       (.C(CLK),
        .CE(pf_r_valid),
        .D(\pc_reg0_inferred__0/pc[3]__0_i_1_n_0 ),
        .Q(\pc_reg[9]__0_0 [3]),
        .R(instr_fifo_n_5));
  FDRE #(
    .INIT(1'b0)) 
    \pc_reg[4]__0 
       (.C(CLK),
        .CE(pf_r_valid),
        .D(\pc_reg0_inferred__0/pc[4]__0_i_1_n_0 ),
        .Q(\pc_reg[9]__0_0 [4]),
        .R(instr_fifo_n_5));
  FDRE #(
    .INIT(1'b0)) 
    \pc_reg[5]__0 
       (.C(CLK),
        .CE(pf_r_valid),
        .D(\pc_reg0_inferred__0/pc[5]__0_i_1_n_0 ),
        .Q(\pc_reg[9]__0_0 [5]),
        .R(instr_fifo_n_5));
  FDRE #(
    .INIT(1'b0)) 
    \pc_reg[6]__0 
       (.C(CLK),
        .CE(pf_r_valid),
        .D(\pc_reg0_inferred__0/pc[6]__0_i_1_n_0 ),
        .Q(\pc_reg[9]__0_0 [6]),
        .R(instr_fifo_n_5));
  FDRE #(
    .INIT(1'b0)) 
    \pc_reg[7]__0 
       (.C(CLK),
        .CE(pf_r_valid),
        .D(\pc_reg0_inferred__0/pc[7]__0_i_1_n_0 ),
        .Q(\pc_reg[9]__0_0 [7]),
        .R(instr_fifo_n_5));
  FDRE #(
    .INIT(1'b0)) 
    \pc_reg[8]__0 
       (.C(CLK),
        .CE(pf_r_valid),
        .D(\pc_reg0_inferred__0/pc[8]__0_i_1_n_0 ),
        .Q(\pc_reg[9]__0_0 [8]),
        .R(instr_fifo_n_5));
  FDRE #(
    .INIT(1'b0)) 
    \pc_reg[9]__0 
       (.C(CLK),
        .CE(pf_r_valid),
        .D(\pc_reg0_inferred__0/pc[9]__0_i_2_n_0 ),
        .Q(\pc_reg[9]__0_0 [9]),
        .R(instr_fifo_n_5));
endmodule

module prefetch_fifo
   (E,
    Q,
    SR,
    \occ_reg[3]_0 ,
    if_valid,
    rst_n_IBUF,
    CLK);
  output [0:0]E;
  output [3:0]Q;
  output [0:0]SR;
  output \occ_reg[3]_0 ;
  input if_valid;
  input rst_n_IBUF;
  input CLK;

  wire CLK;
  wire [0:0]E;
  wire [3:0]Q;
  wire [0:0]SR;
  wire if_valid;
  wire \occ[0]_i_1_n_0 ;
  wire \occ[1]_i_1_n_0 ;
  wire \occ[2]_i_1_n_0 ;
  wire \occ[3]_i_2_n_0 ;
  wire \occ_reg[3]_0 ;
  wire rptr0__0;
  wire rst_n_IBUF;

  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'hFFFE0000)) 
    if_valid_i_1
       (.I0(Q[3]),
        .I1(Q[0]),
        .I2(Q[1]),
        .I3(Q[2]),
        .I4(rst_n_IBUF),
        .O(\occ_reg[3]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \occ[0]_i_1 
       (.I0(Q[0]),
        .O(\occ[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT4 #(
    .INIT(16'hC3C2)) 
    \occ[1]_i_1 
       (.I0(Q[3]),
        .I1(Q[0]),
        .I2(Q[1]),
        .I3(Q[2]),
        .O(\occ[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'hF0C2)) 
    \occ[2]_i_1 
       (.I0(Q[3]),
        .I1(Q[0]),
        .I2(Q[2]),
        .I3(Q[1]),
        .O(\occ[2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hAAAAAAA8)) 
    \occ[3]_i_1 
       (.I0(if_valid),
        .I1(Q[3]),
        .I2(Q[0]),
        .I3(Q[1]),
        .I4(Q[2]),
        .O(rptr0__0));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'hF0E0)) 
    \occ[3]_i_2 
       (.I0(Q[0]),
        .I1(Q[1]),
        .I2(Q[3]),
        .I3(Q[2]),
        .O(\occ[3]_i_2_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \occ_reg[0] 
       (.C(CLK),
        .CE(rptr0__0),
        .D(\occ[0]_i_1_n_0 ),
        .Q(Q[0]),
        .R(SR));
  FDRE #(
    .INIT(1'b0)) 
    \occ_reg[1] 
       (.C(CLK),
        .CE(rptr0__0),
        .D(\occ[1]_i_1_n_0 ),
        .Q(Q[1]),
        .R(SR));
  FDRE #(
    .INIT(1'b0)) 
    \occ_reg[2] 
       (.C(CLK),
        .CE(rptr0__0),
        .D(\occ[2]_i_1_n_0 ),
        .Q(Q[2]),
        .R(SR));
  FDRE #(
    .INIT(1'b0)) 
    \occ_reg[3] 
       (.C(CLK),
        .CE(rptr0__0),
        .D(\occ[3]_i_2_n_0 ),
        .Q(Q[3]),
        .R(SR));
  LUT1 #(
    .INIT(2'h1)) 
    \pc[9]__0_i_1 
       (.I0(rst_n_IBUF),
        .O(SR));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'hFFFE)) 
    r_valid
       (.I0(Q[2]),
        .I1(Q[1]),
        .I2(Q[0]),
        .I3(Q[3]),
        .O(E));
endmodule

(* NotValidForBitStream *)
module top_pipeline
   (clk,
    rst_n,
    dbg_pc,
    dbg_if_insn,
    dbg_pf_occ,
    dbg_reg1);
  input clk;
  input rst_n;
  output [31:0]dbg_pc;
  output [31:0]dbg_if_insn;
  output [7:0]dbg_pf_occ;
  output [31:0]dbg_reg1;

  wire clk;
  wire clk_IBUF;
  wire clk_IBUF_BUFG;
  wire [31:0]dbg_if_insn;
  wire [31:0]dbg_pc;
  wire [9:0]dbg_pc_OBUF;
  wire [7:0]dbg_pf_occ;
  wire [3:0]dbg_pf_occ_OBUF;
  wire [31:0]dbg_reg1;
  wire n_0_16;
  wire rst_n;
  wire rst_n_IBUF;

  BUFG clk_IBUF_BUFG_inst
       (.I(clk_IBUF),
        .O(clk_IBUF_BUFG));
  IBUF clk_IBUF_inst
       (.I(clk),
        .O(clk_IBUF));
  pipeline_core core
       (.CLK(clk_IBUF_BUFG),
        .Q(dbg_pf_occ_OBUF),
        .\pc_reg[9]__0_0 (dbg_pc_OBUF),
        .rst_n_IBUF(rst_n_IBUF));
  OBUF \dbg_if_insn_OBUF[0]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[0]));
  OBUF \dbg_if_insn_OBUF[10]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[10]));
  OBUF \dbg_if_insn_OBUF[11]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[11]));
  OBUF \dbg_if_insn_OBUF[12]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[12]));
  OBUF \dbg_if_insn_OBUF[13]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[13]));
  OBUF \dbg_if_insn_OBUF[14]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[14]));
  OBUF \dbg_if_insn_OBUF[15]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[15]));
  OBUF \dbg_if_insn_OBUF[16]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[16]));
  OBUF \dbg_if_insn_OBUF[17]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[17]));
  OBUF \dbg_if_insn_OBUF[18]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[18]));
  OBUF \dbg_if_insn_OBUF[19]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[19]));
  OBUF \dbg_if_insn_OBUF[1]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[1]));
  OBUF \dbg_if_insn_OBUF[20]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[20]));
  OBUF \dbg_if_insn_OBUF[21]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[21]));
  OBUF \dbg_if_insn_OBUF[22]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[22]));
  OBUF \dbg_if_insn_OBUF[23]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[23]));
  OBUF \dbg_if_insn_OBUF[24]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[24]));
  OBUF \dbg_if_insn_OBUF[25]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[25]));
  OBUF \dbg_if_insn_OBUF[26]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[26]));
  OBUF \dbg_if_insn_OBUF[27]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[27]));
  OBUF \dbg_if_insn_OBUF[28]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[28]));
  OBUF \dbg_if_insn_OBUF[29]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[29]));
  OBUF \dbg_if_insn_OBUF[2]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[2]));
  OBUF \dbg_if_insn_OBUF[30]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[30]));
  OBUF \dbg_if_insn_OBUF[31]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[31]));
  OBUF \dbg_if_insn_OBUF[3]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[3]));
  OBUF \dbg_if_insn_OBUF[4]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[4]));
  OBUF \dbg_if_insn_OBUF[5]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[5]));
  OBUF \dbg_if_insn_OBUF[6]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[6]));
  OBUF \dbg_if_insn_OBUF[7]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[7]));
  OBUF \dbg_if_insn_OBUF[8]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[8]));
  OBUF \dbg_if_insn_OBUF[9]_inst 
       (.I(1'b0),
        .O(dbg_if_insn[9]));
  OBUF \dbg_pc_OBUF[0]_inst 
       (.I(dbg_pc_OBUF[0]),
        .O(dbg_pc[0]));
  OBUF \dbg_pc_OBUF[10]_inst 
       (.I(1'b0),
        .O(dbg_pc[10]));
  OBUF \dbg_pc_OBUF[11]_inst 
       (.I(1'b0),
        .O(dbg_pc[11]));
  OBUF \dbg_pc_OBUF[12]_inst 
       (.I(1'b0),
        .O(dbg_pc[12]));
  OBUF \dbg_pc_OBUF[13]_inst 
       (.I(1'b0),
        .O(dbg_pc[13]));
  OBUF \dbg_pc_OBUF[14]_inst 
       (.I(1'b0),
        .O(dbg_pc[14]));
  OBUF \dbg_pc_OBUF[15]_inst 
       (.I(1'b0),
        .O(dbg_pc[15]));
  OBUF \dbg_pc_OBUF[16]_inst 
       (.I(1'b0),
        .O(dbg_pc[16]));
  OBUF \dbg_pc_OBUF[17]_inst 
       (.I(1'b0),
        .O(dbg_pc[17]));
  OBUF \dbg_pc_OBUF[18]_inst 
       (.I(1'b0),
        .O(dbg_pc[18]));
  OBUF \dbg_pc_OBUF[19]_inst 
       (.I(1'b0),
        .O(dbg_pc[19]));
  OBUF \dbg_pc_OBUF[1]_inst 
       (.I(dbg_pc_OBUF[1]),
        .O(dbg_pc[1]));
  OBUF \dbg_pc_OBUF[20]_inst 
       (.I(1'b0),
        .O(dbg_pc[20]));
  OBUF \dbg_pc_OBUF[21]_inst 
       (.I(1'b0),
        .O(dbg_pc[21]));
  OBUF \dbg_pc_OBUF[22]_inst 
       (.I(1'b0),
        .O(dbg_pc[22]));
  OBUF \dbg_pc_OBUF[23]_inst 
       (.I(1'b0),
        .O(dbg_pc[23]));
  OBUF \dbg_pc_OBUF[24]_inst 
       (.I(1'b0),
        .O(dbg_pc[24]));
  OBUF \dbg_pc_OBUF[25]_inst 
       (.I(1'b0),
        .O(dbg_pc[25]));
  OBUF \dbg_pc_OBUF[26]_inst 
       (.I(1'b0),
        .O(dbg_pc[26]));
  OBUF \dbg_pc_OBUF[27]_inst 
       (.I(1'b0),
        .O(dbg_pc[27]));
  OBUF \dbg_pc_OBUF[28]_inst 
       (.I(1'b0),
        .O(dbg_pc[28]));
  OBUF \dbg_pc_OBUF[29]_inst 
       (.I(1'b0),
        .O(dbg_pc[29]));
  OBUF \dbg_pc_OBUF[2]_inst 
       (.I(dbg_pc_OBUF[2]),
        .O(dbg_pc[2]));
  OBUF \dbg_pc_OBUF[30]_inst 
       (.I(1'b0),
        .O(dbg_pc[30]));
  OBUF \dbg_pc_OBUF[31]_inst 
       (.I(1'b0),
        .O(dbg_pc[31]));
  OBUF \dbg_pc_OBUF[3]_inst 
       (.I(dbg_pc_OBUF[3]),
        .O(dbg_pc[3]));
  OBUF \dbg_pc_OBUF[4]_inst 
       (.I(dbg_pc_OBUF[4]),
        .O(dbg_pc[4]));
  OBUF \dbg_pc_OBUF[5]_inst 
       (.I(dbg_pc_OBUF[5]),
        .O(dbg_pc[5]));
  OBUF \dbg_pc_OBUF[6]_inst 
       (.I(dbg_pc_OBUF[6]),
        .O(dbg_pc[6]));
  OBUF \dbg_pc_OBUF[7]_inst 
       (.I(dbg_pc_OBUF[7]),
        .O(dbg_pc[7]));
  OBUF \dbg_pc_OBUF[8]_inst 
       (.I(dbg_pc_OBUF[8]),
        .O(dbg_pc[8]));
  OBUF \dbg_pc_OBUF[9]_inst 
       (.I(dbg_pc_OBUF[9]),
        .O(dbg_pc[9]));
  OBUF \dbg_pf_occ_OBUF[0]_inst 
       (.I(dbg_pf_occ_OBUF[0]),
        .O(dbg_pf_occ[0]));
  OBUF \dbg_pf_occ_OBUF[1]_inst 
       (.I(dbg_pf_occ_OBUF[1]),
        .O(dbg_pf_occ[1]));
  OBUF \dbg_pf_occ_OBUF[2]_inst 
       (.I(dbg_pf_occ_OBUF[2]),
        .O(dbg_pf_occ[2]));
  OBUF \dbg_pf_occ_OBUF[3]_inst 
       (.I(dbg_pf_occ_OBUF[3]),
        .O(dbg_pf_occ[3]));
  OBUF \dbg_pf_occ_OBUF[4]_inst 
       (.I(1'b0),
        .O(dbg_pf_occ[4]));
  OBUF \dbg_pf_occ_OBUF[5]_inst 
       (.I(1'b0),
        .O(dbg_pf_occ[5]));
  OBUF \dbg_pf_occ_OBUF[6]_inst 
       (.I(1'b0),
        .O(dbg_pf_occ[6]));
  OBUF \dbg_pf_occ_OBUF[7]_inst 
       (.I(1'b0),
        .O(dbg_pf_occ[7]));
  OBUF \dbg_reg1_OBUF[0]_inst 
       (.I(1'b0),
        .O(dbg_reg1[0]));
  OBUF \dbg_reg1_OBUF[10]_inst 
       (.I(1'b0),
        .O(dbg_reg1[10]));
  OBUF \dbg_reg1_OBUF[11]_inst 
       (.I(1'b0),
        .O(dbg_reg1[11]));
  OBUF \dbg_reg1_OBUF[12]_inst 
       (.I(1'b0),
        .O(dbg_reg1[12]));
  OBUF \dbg_reg1_OBUF[13]_inst 
       (.I(1'b0),
        .O(dbg_reg1[13]));
  OBUF \dbg_reg1_OBUF[14]_inst 
       (.I(1'b0),
        .O(dbg_reg1[14]));
  OBUF \dbg_reg1_OBUF[15]_inst 
       (.I(1'b0),
        .O(dbg_reg1[15]));
  OBUF \dbg_reg1_OBUF[16]_inst 
       (.I(1'b0),
        .O(dbg_reg1[16]));
  OBUF \dbg_reg1_OBUF[17]_inst 
       (.I(1'b0),
        .O(dbg_reg1[17]));
  OBUF \dbg_reg1_OBUF[18]_inst 
       (.I(1'b0),
        .O(dbg_reg1[18]));
  OBUF \dbg_reg1_OBUF[19]_inst 
       (.I(1'b0),
        .O(dbg_reg1[19]));
  OBUF \dbg_reg1_OBUF[1]_inst 
       (.I(1'b0),
        .O(dbg_reg1[1]));
  OBUF \dbg_reg1_OBUF[20]_inst 
       (.I(1'b0),
        .O(dbg_reg1[20]));
  OBUF \dbg_reg1_OBUF[21]_inst 
       (.I(1'b0),
        .O(dbg_reg1[21]));
  OBUF \dbg_reg1_OBUF[22]_inst 
       (.I(1'b0),
        .O(dbg_reg1[22]));
  OBUF \dbg_reg1_OBUF[23]_inst 
       (.I(1'b0),
        .O(dbg_reg1[23]));
  OBUF \dbg_reg1_OBUF[24]_inst 
       (.I(1'b0),
        .O(dbg_reg1[24]));
  OBUF \dbg_reg1_OBUF[25]_inst 
       (.I(1'b0),
        .O(dbg_reg1[25]));
  OBUF \dbg_reg1_OBUF[26]_inst 
       (.I(1'b0),
        .O(dbg_reg1[26]));
  OBUF \dbg_reg1_OBUF[27]_inst 
       (.I(1'b0),
        .O(dbg_reg1[27]));
  OBUF \dbg_reg1_OBUF[28]_inst 
       (.I(1'b0),
        .O(dbg_reg1[28]));
  OBUF \dbg_reg1_OBUF[29]_inst 
       (.I(1'b0),
        .O(dbg_reg1[29]));
  OBUF \dbg_reg1_OBUF[2]_inst 
       (.I(1'b0),
        .O(dbg_reg1[2]));
  OBUF \dbg_reg1_OBUF[30]_inst 
       (.I(1'b0),
        .O(dbg_reg1[30]));
  OBUF \dbg_reg1_OBUF[31]_inst 
       (.I(1'b0),
        .O(dbg_reg1[31]));
  OBUF \dbg_reg1_OBUF[3]_inst 
       (.I(1'b0),
        .O(dbg_reg1[3]));
  OBUF \dbg_reg1_OBUF[4]_inst 
       (.I(1'b0),
        .O(dbg_reg1[4]));
  OBUF \dbg_reg1_OBUF[5]_inst 
       (.I(1'b0),
        .O(dbg_reg1[5]));
  OBUF \dbg_reg1_OBUF[6]_inst 
       (.I(1'b0),
        .O(dbg_reg1[6]));
  OBUF \dbg_reg1_OBUF[7]_inst 
       (.I(1'b0),
        .O(dbg_reg1[7]));
  OBUF \dbg_reg1_OBUF[8]_inst 
       (.I(1'b0),
        .O(dbg_reg1[8]));
  OBUF \dbg_reg1_OBUF[9]_inst 
       (.I(1'b0),
        .O(dbg_reg1[9]));
  LUT1 #(
    .INIT(2'h1)) 
    i_16
       (.I0(rst_n_IBUF),
        .O(n_0_16));
  IBUF rst_n_IBUF_inst
       (.I(rst_n),
        .O(rst_n_IBUF));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
