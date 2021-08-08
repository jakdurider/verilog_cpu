`define WORD_SIZE 16
`include "opcodes.v"

module control_unit(
    input [`WORD_SIZE-1:0] inst,
    input clk,
    input reset_n,
    
    output PCWriteCond,
    output PCWrite,
    output IorD,
    output MemRead,
    output MemWrite,
    output MemtoReg,
    output IRWrite,
    output [1:0] PCSource,
    output [1:0] ALUSrcB,
    output ALUSrcA,
    output RegWrite,
    output [1:0] RegDst,
    
    output [3:0] ALUOp,
    output [5:0] func,
    
    output is_halted
);
    wire [3:0] state;
    state_machine m_state_machine(
        .inst(inst), .clk(clk), .state(state), .reset_n(reset_n)
    );
    ROM m_ROM(
        .state(state), .inst(inst),
        .PCWriteCond(PCWriteCond), .PCWrite(PCWrite),
        .IorD(IorD), .MemRead(MemRead),
        .MemWrite(MemWrite), .MemtoReg(MemtoReg),
        .IRWrite(IRWrite), .PCSource(PCSource),
        .ALUOp(ALUOp), .func(func), .ALUSrcB(ALUSrcB),
        .ALUSrcA(ALUSrcA), .RegWrite(RegWrite),
        .RegDst(RegDst), .is_halted(is_halted)
    );
endmodule