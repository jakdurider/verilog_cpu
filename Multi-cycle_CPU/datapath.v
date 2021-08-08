`define WORD_SIZE 16

module datapath(
    input [`WORD_SIZE-1:0] inst,
    output [`WORD_SIZE-1:0] inst_to_control_unit,
    
    input clk,
    input reset_n,
    
    //control signals
    input PCWriteCond,
    input PCWrite,
    input IorD,
    input MemRead,
    input MemWrite,
    input MemtoReg,
    input IRWrite,
    input [1:0] PCSource,
    input [3:0] ALUOp,
    input [5:0] func,
    input [1:0] ALUSrcB,
    input ALUSrcA,
    input RegWrite,
    input [1:0] RegDst,
    
    output [`WORD_SIZE-1:0] output_port,
    output [`WORD_SIZE-1:0] MEM_write_data,
    output [`WORD_SIZE-1:0] MEM_addr,
    input [`WORD_SIZE-1:0] MEM_result
);
    //PC data
    reg [`WORD_SIZE-1:0] PC;
    wire [`WORD_SIZE-1:0] next_PC;
    initial begin
        PC <= 0;
    end
    //instruction data
    reg [`WORD_SIZE-1:0] inst_reg;
    always @(posedge clk) begin
        if(IRWrite) inst_reg <= inst;
    end
    assign inst_to_control_unit = inst_reg;
    
    // RF datas
    wire [1:0] RF_write_addr;
    wire [`WORD_SIZE-1:0] RF_result1;
    wire [`WORD_SIZE-1:0] RF_result2;
    wire [`WORD_SIZE-1:0] RF_write_data;
    reg [`WORD_SIZE-1:0] RF_result1_reg;
    reg [`WORD_SIZE-1:0] RF_result2_reg;
    always @(posedge clk) begin
        RF_result1_reg <= RF_result1;
        RF_result2_reg <= RF_result2;
    end
    
    // ALU datas
    wire [`WORD_SIZE-1:0] ALUin1;
    wire [`WORD_SIZE-1:0] ALUin2;
    wire [`WORD_SIZE-1:0] ALU_result;
    wire zero;
    wire [`WORD_SIZE-1:0] sign_extended_immediate;
    assign sign_extended_immediate = {{8{inst[7]}},inst[7:0]};
    reg [`WORD_SIZE-1:0] ALUOut;
    always @(posedge clk) begin
        ALUOut <= ALU_result;
    end
    
    //MEM datas
    assign MEM_write_data = RF_result2_reg;
    reg [`WORD_SIZE-1:0] MEM_data_reg;
    always @(posedge clk) begin
        MEM_data_reg <= MEM_result;
    end
    
    //RF mux
    assign RF_write_addr = RegDst==2'd2 ? 2'd2 : (RegDst==2'd1 ? inst_reg[7:6] : inst_reg[9:8]);
    assign RF_write_data = MemtoReg ? MEM_data_reg : ALUOut;
    
    // ALU mux
    assign ALUin1 = ALUSrcA ? RF_result1_reg : PC;
    assign ALUin2 = ALUSrcB==2'd2 ? sign_extended_immediate : (ALUSrcB==2'd1 ? 16'd1 : RF_result2_reg);
    
    // MEM mux
    assign MEM_addr = IorD ? ALUOut : PC;
    
    // make output
    assign output_port = (ALUOp==4'd15 && func==6'd28) ? RF_result1 : output_port;
    
    // PC control
    assign next_PC = PCSource ==2'd3 ? RF_result1 : (PCSource==2'd2 ? {PC[15:12],inst_reg[11:0]} : (PCSource==2'd1 ? ALUOut : ALU_result));
    always @(posedge clk) begin
        if( PCWrite | (PCWriteCond & zero)) PC <= next_PC;
    end
    
    RF m_RF(
        .write(RegWrite), .clk(clk), .reset_n(reset_n),
        .addr1(inst_reg[11:10]), .addr2(inst_reg[9:8]), .addr3(RF_write_addr),
        .data1(RF_result1), .data2(RF_result2), .data3(RF_write_data)
    );
    
    ALU m_ALU(
        .A(ALUin1), .B(ALUin2), .opcode(ALUOp),
        .func(func), .C(ALU_result), .zero(zero)
    );
endmodule