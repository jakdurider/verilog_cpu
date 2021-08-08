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
        output is_halted,
        
    // for DMA
        input DMA_begin,
        input DMA_end,
        output reg BG,
        input BR,
        output reg [`WORD_SIZE-1:0] DMA_command
);

//for DMA
always @(posedge DMA_begin) begin
    DMA_command = 16'hc1f4;
end
always @(negedge BR) begin
    DMA_command = 16'bz;
end

// after get BR, complete current memory access and give BG
reg DMA_waiting = 0;
wire accessing_memory;

always @(posedge Clk) begin
    if(BR) begin
        if(!accessing_memory) BG = 1;
        else BG = 0; // wait until cpu relax memory bus
    end
    else begin
        BG = 0; // clear BG after DMA
    end
end

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

wire d_writeM_sub;
assign d_writeM = !BG ? d_writeM_sub : 1'bz;
wire [`WORD_SIZE-1:0] d_address_sub;
assign d_address = !BG ? d_address_sub : `WORD_SIZE'bz;
//wire [`LINE_SIZE-1:0] d_data_sub;
//assign d_data = !BG ? d_data_sub : `LINE_SIZE'bz;

datapath m_datapath(
  .i_data(i_data), .i_address(i_address),
  .inst_to_control_unit(inst_to_control_unit),
  .d_data(d_data), .d_address(d_address_sub),
  .clk(Clk), .reset_n(Reset_N),
  .PCSrc(PCSrc), .ALUSrc(ALUSrc),
  .ALUOp(ALUOp), .func(func),
  .RegDst(RegDst), .MemWrite(MemWrite),
  .MemRead(MemRead), .MemtoReg(MemtoReg), .LinkJump(LinkJump),
  .RegWrite(RegWrite), .output_port(output_port),
  .stall(stall), .num_inst(num_inst),
  .d_readM(d_readM), .d_writeM(d_writeM_sub),
  .i_readM(i_readM), .i_writeM(i_writeM),
  .i_stall(i_stall), .BG(BG), .accessing_memory(accessing_memory)
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
