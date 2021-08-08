`define WORD_SIZE 16

module PC_control(
    input [`WORD_SIZE-1:0] PC,
    output [`WORD_SIZE-1:0] next_PC,
    input Jump,
    input Branch,
    input [`WORD_SIZE-1:0] immediate
);

    //wire [`WORD_SIZE-1:0] branch_PC;
    
    //assign branch_PC = Branch ? PC+immediate : PC+1;
    assign next_PC = Jump ? {PC[15:12], {4{1'b0}}, immediate[7:0]} : PC+1;   
    
endmodule