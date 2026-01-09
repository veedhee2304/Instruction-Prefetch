`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2025 07:08:23 AM
// Design Name: 
// Module Name: top_pipeline
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


module top_pipeline (
    input  wire clk,
    input  wire rst_n,

    // Add outputs so Vivado does NOT optimize design away
    output wire [31:0] dbg_pc,
    output wire [31:0] dbg_if_insn,
    output wire [7:0]  dbg_pf_occ,
    output wire [31:0] dbg_reg1
);

    // Instantiate your pipeline core
    pipeline_core #(
        .ADDR_WIDTH(10),
        .PF_DEPTH(8)
    ) core (
        .clk(clk),
        .rst_n(rst_n),
        .dbg_if_insn(dbg_if_insn),
        .dbg_pc(dbg_pc),
        .dbg_pf_occ(dbg_pf_occ),
        .dbg_reg1(dbg_reg1)
    );

endmodule
