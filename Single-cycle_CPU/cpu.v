//DEFINITIONS 
`define WORD_SIZE 16

//INCLUDE files
// `include "opcodes.v"

//MODULE DECLARATION

module cpu(
    output readM,
    output [`WORD_SIZE-1:0] address,
    input [`WORD_SIZE-1:0] data,
    input inputReady,
    input reset_n,
    input clk,
    
    //for debugging/testing purpose
    output [`WORD_SIZE-1:0] num_inst,
    output [`WORD_SIZE-1:0] output_port
);
    
    reg [`WORD_SIZE-1:0] num_inst_reg;
    assign num_inst = num_inst_reg;
    
    reg readM_reg;
    assign readM = readM_reg;
    
    reg [`WORD_SIZE-1:0] inst;
    
    reg [`WORD_SIZE-1:0] PC;
    wire [`WORD_SIZE-1:0] next_PC;
    assign address = PC;
    
    initial begin
        num_inst_reg <= 0;
        PC <= -1;
    end
    
    
    
    always @(posedge clk) begin
        if(reset_n)begin
            num_inst_reg <= num_inst_reg + 1;
            PC <= next_PC;
            readM_reg <= 1;
        end
    end
    always @(posedge inputReady) begin
        inst <= data;
        readM_reg <= 0;
    end
   
        
    //control signals
    wire RegDst;
    wire Jump;
    wire Branch;
    wire MemRead;
    wire MemtoReg;
    wire [3:0] ALUOp;
    wire [5:0] func;
    wire MemWrite;
    wire ALUSrc;
    wire RegWrite;
    
    datapath m_datapath(
            .inst(inst), .clk(clk) ,.reset_n(reset_n),
            .PC(PC), .next_PC(next_PC),
            .RegDst(RegDst), .Jump(Jump),
            .Branch(Branch), .MemRead(MemRead), .MemtoReg(MemtoReg),
            .ALUOp(ALUOp), .func(func), .MemWrite(MemWrite), .ALUSrc(ALUSrc),
            .RegWrite(RegWrite), .output_port(output_port)
    );
    
    control_unit m_control_unit(
            .inst(inst), .RegDst(RegDst), .Jump(Jump),
            .Branch(Branch), .MemRead(MemRead), .MemtoReg(MemtoReg),
            .ALUOp(ALUOp), .func(func), .MemWrite(MemWrite), .ALUSrc(ALUSrc),
            .RegWrite(RegWrite)
    );  
    


endmodule