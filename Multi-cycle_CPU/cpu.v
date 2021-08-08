`timescale 1ns/100ps

`include "opcodes.v"
`include "constants.v"

module cpu (
    output readM, // read from memory
    output writeM, // write to memory
    output [`WORD_SIZE-1:0] address, // current address for data
    inout [`WORD_SIZE-1:0] data, // data being input or output
    input inputReady, // indicates that data is ready from the input port
    input reset_n, // active-low RESET signal
    input clk, // clock signal
    
    // for debuging/testing purpose
    output [`WORD_SIZE-1:0] num_inst, // number of instruction during execution
    output [`WORD_SIZE-1:0] output_port, // this will be used for a "WWD" instruction
    output is_halted // 1 if the cpu is halted
);
    // ... fill in the rest of the code
    reg [`WORD_SIZE-1:0] num_inst_reg;
    assign num_inst = num_inst_reg;
    
    reg [`WORD_SIZE-1:0] inst;
    initial begin
        num_inst_reg <= 0;
    end
    
    //control signals
    wire PCWriteCond;
    wire PCWrite;
    wire IorD;
    wire MemRead;
    wire MemWrite;
    wire MemtoReg;
    wire IRWrite;
    wire [1:0] PCSource;
    wire [3:0] ALUOp;
    wire [5:0] func;
    wire [1:0] ALUSrcB;
    wire ALUSrcA;
    wire RegWrite;
    wire [1:0] RegDst;
    
    //when do we need to increase num_inst_reg?
    always @(posedge clk) begin
        if(IRWrite==1 && reset_n == 1) num_inst_reg <= num_inst_reg + 1;
        // make num_inst increase at each IF/ID 
    end
    
    // MEM signal and data
    
    assign readM = MemRead;
    assign writeM = MemWrite;
    
    wire [`WORD_SIZE-1:0] MEM_addr;
    
    wire [`WORD_SIZE-1:0] MEM_write_data;
    reg [`WORD_SIZE-1:0] MEM_result;
    always @(posedge inputReady) begin
        inst <= data; // get instruction from memory
        MEM_result <= data; // get data from memroy
    end
    assign address = MEM_addr;
    
    assign data = writeM ? MEM_write_data : 16'bz; // put data to memory
    
    wire [`WORD_SIZE-1:0] inst_to_control_unit;
    
    datapath m_datapath(
        .inst(inst), .inst_to_control_unit(inst_to_control_unit),
        .clk(clk), .reset_n(reset_n),
        .PCWriteCond(PCWriteCond), .PCWrite(PCWrite),
        .IorD(IorD), .MemRead(MemRead),
        .MemWrite(MemWrite), .MemtoReg(MemtoReg), 
        .IRWrite(IRWrite), .PCSource(PCSource),
        .ALUOp(ALUOp), .func(func), .ALUSrcB(ALUSrcB),
        .ALUSrcA(ALUSrcA), .RegWrite(RegWrite),
        .RegDst(RegDst),
        .output_port(output_port), .MEM_write_data(MEM_write_data),
        .MEM_addr(MEM_addr), .MEM_result(MEM_result)
    );
    
    control_unit m_control_unit(
        .inst(inst_to_control_unit), .clk(clk),
        .PCWriteCond(PCWriteCond), .PCWrite(PCWrite),
        .IorD(IorD), .MemRead(MemRead),
        .MemWrite(MemWrite), .MemtoReg(MemtoReg), 
        .IRWrite(IRWrite), .PCSource(PCSource),
        .ALUOp(ALUOp), .func(func), .ALUSrcB(ALUSrcB),
        .ALUSrcA(ALUSrcA), .RegWrite(RegWrite),
        .RegDst(RegDst),
        .is_halted(is_halted),
        .reset_n(reset_n)
    );
endmodule
