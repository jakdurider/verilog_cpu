`define WORD_SIZE 16

module datapath(
    input [`WORD_SIZE-1:0] inst,
    input clk,
    input reset_n,
    input [`WORD_SIZE-1:0] PC,
    output [`WORD_SIZE-1:0] next_PC,
    
    //control signals
    input RegDst,
    input Jump,
    input Branch,
    input MemRead,
    input MemtoReg,
    input [3:0] ALUOp,
    input [5:0] func,
    input MemWrite,
    input ALUSrc,
    input RegWrite,
    
    output [`WORD_SIZE-1:0] output_port
);
    //RF datas
    wire [1:0] write_addr;
    wire [`WORD_SIZE-1:0] RF_result2;
    wire [`WORD_SIZE-1:0] write_data;
    
    //ALU datas
    wire [`WORD_SIZE-1:0] ALUin1;
    wire [`WORD_SIZE-1:0] ALUin2;
    wire [`WORD_SIZE-1:0] ALU_result;
    wire [`WORD_SIZE-1:0] sign_extended_immediate;
    
    //MEM datas
    wire [`WORD_SIZE-1:0] MEM_result;
    
    //output datas
    
    // RF mux
    assign write_addr = RegDst? inst[7:6] : inst[9:8];
    assign write_data = MemtoReg? MEM_result : ALU_result;
    
    // ALU mux
    assign sign_extended_immediate = {{8{inst[7]}},inst[7:0]};
    assign ALUin2 = ALUSrc ? sign_extended_immediate : RF_result2;
    
    // make output
    assign output_port = (ALUOp == 4'd15 && func == 6'd28) ? ALUin1 : output_port;
    
    RF m_RF(.write(RegWrite),.clk(clk),.reset_n(reset_n),
            .addr1(inst[11:10]), .addr2(inst[9:8]), .addr3(write_addr),
               .data1(ALUin1), .data2(RF_result2), .data3(write_data)
               );
    
    ALU m_ALU(.A(ALUin1), .B(ALUin2), .opcode(ALUOp),
            .func(func), .C(ALU_result)
            );
    
    PC_control m_PC_control(.PC(PC), .next_PC(next_PC),
                            .Jump(Jump), .Branch(Branch), .immediate(sign_extended_immediate)
            );

endmodule    