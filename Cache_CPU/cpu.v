`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size
`define LINE_SIZE 64
`include "opcodes.v"

module cpu(
        input Clk, 
        input Reset_N, 

	// Instruction memory interface
        output i_readM, 
        output i_writeM, 
        output [`WORD_SIZE-1:0] i_address, 
        inout [`LINE_SIZE-1:0] i_data, 

	// Data memory interface
        output d_readM, 
        output d_writeM, 
        output [`WORD_SIZE-1:0] d_address, 
        inout [`LINE_SIZE-1:0] d_data, 

        output [`WORD_SIZE-1:0] num_inst, 
        output [`WORD_SIZE-1:0] output_port, 
        output is_halted
);

wire [`WORD_SIZE-1:0] inst_to_control_unit;

//control signals
wire [1:0] PCSrc;
wire ALUSrc;
wire [1:0] RegDst;
wire MemWrite;
wire MemRead;
wire MemtoReg;
wire LinkJump;
wire RegWrite;
//wire is_halted;

wire [3:0] ALUOp;
wire [5:0] func;

wire stall;
wire i_stall;


datapath m_datapath(
  .i_data(i_data), .i_address(i_address),
  .inst_to_control_unit(inst_to_control_unit),
  .d_data(d_data), .d_address(d_address),
  .clk(Clk), .reset_n(Reset_N),
  .PCSrc(PCSrc), .ALUSrc(ALUSrc),
  .ALUOp(ALUOp), .func(func),
  .RegDst(RegDst), .MemWrite(MemWrite),
  .MemRead(MemRead), .MemtoReg(MemtoReg), .LinkJump(LinkJump),
  .RegWrite(RegWrite), .output_port(output_port),
  .stall(stall), .num_inst(num_inst),
  .d_readM(d_readM), .d_writeM(d_writeM),
  .i_readM(i_readM), .i_writeM(i_writeM),
  .i_stall(i_stall)
);

control_unit m_control_unit(
  .inst(inst_to_control_unit), .stall(stall),
  .PCSrc(PCSrc), .ALUSrc(ALUSrc),
  .RegDst(RegDst), .MemWrite(MemWrite),
  .MemRead(MemRead), .MemtoReg(MemtoReg), .LinkJump(LinkJump),
  .RegWrite(RegWrite), .is_halted(is_halted),
  .ALUOp(ALUOp), .func(func),
  .i_stall(i_stall), .clk(Clk)
);

endmodule
