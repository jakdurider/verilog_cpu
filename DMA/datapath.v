`define WORD_SIZE 16
`define LINE_SIZE 64

module datapath(
  inout [`LINE_SIZE-1:0] i_data,
  output [`WORD_SIZE-1:0] i_address,
  output i_readM,
  output i_writeM,
  output [`WORD_SIZE-1:0] inst_to_control_unit,
  
  inout [`LINE_SIZE-1:0] d_data,
  output [`WORD_SIZE-1:0] d_address,
  output d_readM,      
  output d_writeM,     
  
  input clk,
  input reset_n,
  
  //control signals
  input [1:0] PCSrc,
  input ALUSrc,
  input [3:0] ALUOp,
  input [5:0] func,
  input [1:0] RegDst,
  input MemWrite,
  input MemRead,
  input MemtoReg,
  input LinkJump,
  input RegWrite,
  
  output [`WORD_SIZE-1:0] output_port,
  output stall,
  output i_stall,

  output [`WORD_SIZE-1:0] num_inst,
  
  input BG,
  output accessing_memory
);

// stall by memory access
//wire i_stall;
wire d_stall;

wire stall_from_hazard_unit;

assign stall = stall_from_hazard_unit | i_stall | d_stall;

//control signal register
reg ALUSrc_EX;
reg [3:0] ALUOp_EX;
reg [5:0] func_EX;
reg [1:0] RegDst_EX;
reg MemWrite_EX;
reg MemRead_EX;
reg MemtoReg_EX;
reg LinkJump_EX;
reg RegWrite_EX;

reg MemWrite_MEM;
reg MemRead_MEM;
reg MemtoReg_MEM;
reg LinkJump_MEM;
reg RegWrite_MEM;

reg MemtoReg_WB;
reg LinkJump_WB;
reg RegWrite_WB;

reg RegWrite_WB_temp;

//control signal update
always @(posedge clk) begin
    if(!d_stall) begin
      ALUSrc_EX <= ALUSrc;
      ALUOp_EX <= ALUOp;
      func_EX <= func;
      RegDst_EX <= RegDst;
      MemWrite_EX <= MemWrite;
      MemRead_EX <= MemRead;
      MemtoReg_EX <= MemtoReg;
      LinkJump_EX <= LinkJump;
      RegWrite_EX <= RegWrite;
      
      MemWrite_MEM <= MemWrite_EX;
      MemRead_MEM <= MemRead_EX;
      MemtoReg_MEM <= MemtoReg_EX;
      LinkJump_MEM <= LinkJump_EX;
      RegWrite_MEM <= RegWrite_EX;
  
      MemtoReg_WB <= MemtoReg_MEM;
      LinkJump_WB <= LinkJump_MEM;
      RegWrite_WB <= RegWrite_MEM;    
    end
end

always @(d_stall) begin
    if(d_stall) begin
        RegWrite_WB_temp = RegWrite;
        RegWrite_WB = 0;
    end
    else begin
        RegWrite_WB = RegWrite_WB_temp;
        RegWrite_WB_temp = 0;
    end
end

//IF stage, branch predictor is at below
reg [`WORD_SIZE-1:0] PC;
initial begin
    PC <= 0;
    RegWrite_WB_temp <= 0;
end
wire [`WORD_SIZE-1:0] branch_predicted_nextPC;
wire [`WORD_SIZE-1:0] i_address_to_cache = PC;
//wire stall;   // for hazard detection unit

//IF_ID register
reg [`WORD_SIZE-1:0] inst_reg;
assign inst_to_control_unit = inst_reg;
reg [`WORD_SIZE-1:0] IF_ID_branch_predicted_nextPC;
reg [`WORD_SIZE-1:0] IF_ID_added_nextPC;
reg [`WORD_SIZE-1:0] IF_ID_PC;
wire [`WORD_SIZE-1:0] i_data_between_cache;

always @(posedge clk) begin
  if(!stall && reset_n) begin
    inst_reg <= i_data_between_cache;
    IF_ID_branch_predicted_nextPC <= branch_predicted_nextPC;
    IF_ID_added_nextPC <= PC + 1;
    IF_ID_PC <= PC;
  end
end

// ID stage, RF and PC decision and branch condition are at below
wire [`WORD_SIZE-1:0] RF_result1;
wire [`WORD_SIZE-1:0] RF_result2;
wire [`WORD_SIZE-1:0] sign_extended_immediate;
assign sign_extended_immediate = {{8{inst_reg[7]}},inst_reg[7:0]};

// ID_EX register
reg [`WORD_SIZE-1:0] ID_EX_added_nextPC;
reg [`WORD_SIZE-1:0] ID_EX_RF_result1;
reg [`WORD_SIZE-1:0] ID_EX_RF_result2;
reg [1:0] ID_EX_rs;
reg [1:0] ID_EX_rt;
reg [1:0] ID_EX_rd;
reg [`WORD_SIZE-1:0] ID_EX_sign_extended_immediate;
wire [`WORD_SIZE-1:0] BranchSrc1;
wire [`WORD_SIZE-1:0] BranchSrc2;
always @(posedge clk) begin
    if(!d_stall) begin
        ID_EX_added_nextPC <= IF_ID_added_nextPC;
        ID_EX_RF_result1 <= BranchSrc1;
        ID_EX_RF_result2 <= BranchSrc2;
        ID_EX_rs <= inst_reg[11:10];
        ID_EX_rt <= inst_reg[9:8];
        ID_EX_rd <= inst_reg[7:6];
        ID_EX_sign_extended_immediate <= sign_extended_immediate;
    end
end

// EX stage, ALU and forwarding logic and unit are at below
wire [`WORD_SIZE-1:0] ALUin1;
wire [`WORD_SIZE-1:0] ALUin2;
wire [`WORD_SIZE-1:0] ALUOut;
wire [1:0] EX_rd_wire;
assign EX_rd_wire = RegDst_EX == 2'd2 ? 2'd2 : (RegDst_EX == 2'd1 ? ID_EX_rd : ID_EX_rt);

// EX_MEM register
reg [`WORD_SIZE-1:0] EX_MEM_added_nextPC;
reg [`WORD_SIZE-1:0] EX_MEM_ALUOut;
reg [`WORD_SIZE-1:0] EX_MEM_RF_result2;
reg [1:0] EX_MEM_rd;
always @(posedge clk) begin
    if(!d_stall) begin
        EX_MEM_added_nextPC <= ID_EX_added_nextPC;
        EX_MEM_ALUOut <= ALUOut;
        EX_MEM_RF_result2 <= ID_EX_RF_result2;
        EX_MEM_rd <= EX_rd_wire;
    end
end

// MEM stage
wire [`WORD_SIZE-1:0] d_data_between_cache;
wire [`WORD_SIZE-1:0] d_address_to_cache = EX_MEM_ALUOut;
assign d_data_between_cache = MemWrite_MEM ? EX_MEM_RF_result2 : 16'bz;
wire [`WORD_SIZE-1:0] MEM_result = d_data_between_cache;

// MEM_WB register
reg [`WORD_SIZE-1:0] MEM_WB_added_nextPC;
reg [`WORD_SIZE-1:0] MEM_WB_MEM_result;
reg [`WORD_SIZE-1:0] MEM_WB_ALUOut;
reg [1:0] MEM_WB_rd;
always @(posedge clk) begin
    MEM_WB_added_nextPC <= EX_MEM_added_nextPC;
    MEM_WB_MEM_result <= MEM_result;
    MEM_WB_ALUOut <= EX_MEM_ALUOut;
    MEM_WB_rd <= EX_MEM_rd;
end

// WB stage
wire [`WORD_SIZE-1:0] WB_write_data;
assign WB_write_data = MemtoReg_WB ? MEM_WB_MEM_result : MEM_WB_ALUOut;
wire [`WORD_SIZE-1:0] RF_write_data;
assign RF_write_data = LinkJump_WB ? MEM_WB_added_nextPC : WB_write_data;
wire [1:0] RF_write_addr;
assign RF_write_addr = MEM_WB_rd;

// ALUSrc forwarding

assign ALUin1 = ID_EX_RF_result1;
wire [`WORD_SIZE-1:0] ALU_input_data2;

assign ALU_input_data2 = ID_EX_RF_result2;
assign ALUin2 = ALUSrc_EX ? ID_EX_sign_extended_immediate : ALU_input_data2;

wire [`WORD_SIZE-1:0] EX_data_final;
wire [`WORD_SIZE-1:0] MEM_data_final;

//nextPC decision
wire zero; //for branch condition
wire [`WORD_SIZE-1:0] PCSrc0;
wire [`WORD_SIZE-1:0] PCSrc1;
wire [`WORD_SIZE-1:0] PCSrc2;
assign PCSrc0 = zero ? IF_ID_added_nextPC + sign_extended_immediate : IF_ID_added_nextPC;
assign PCSrc1 = {IF_ID_PC[15:12],inst_reg[11:0]};

wire [`WORD_SIZE-1:0] MEM_stage_final_result = MemtoReg_MEM ? MEM_result : EX_MEM_ALUOut;

assign PCSrc2 = BranchSrc1;
wire [`WORD_SIZE-1:0] jump_PC;
assign jump_PC = PCSrc == 2'd2 ? PCSrc2 : (PCSrc==2'd1 ? PCSrc1 : PCSrc0);
wire [`WORD_SIZE-1:0] nextPC;
wire jump;
wire unconditional_jump;
assign nextPC = stall && jump ? jump_PC : (stall & !jump ? PC : branch_predicted_nextPC); // weird
always @(posedge clk) begin
    if(reset_n) PC <= nextPC;
end

// branch condition decision
wire [1:0] ForwardBr1;
wire [1:0] ForwardBr2;

assign EX_data_final = LinkJump_EX ? ID_EX_added_nextPC : ALUOut;
assign MEM_data_final = LinkJump_MEM ? EX_MEM_added_nextPC : MEM_stage_final_result;

assign BranchSrc1 = ForwardBr1 == 2'd3 ? RF_write_data : (ForwardBr1 == 2'd2 ? MEM_data_final : (ForwardBr1 == 2'd1 ? EX_data_final : RF_result1));
assign BranchSrc2 = ForwardBr2 == 2'd3 ? RF_write_data : (ForwardBr2 == 2'd2 ? MEM_data_final : (ForwardBr2 == 2'd1 ? EX_data_final : RF_result2));

// make output
assign output_port = ALUOp == 4'd15 && func == 6'd28 ? BranchSrc1 : 16'bz;

// num_inst
reg [`WORD_SIZE-1:0] num_inst_reg;
initial begin
    num_inst_reg = 0;
end

// processing WWD right after LWD and stall
always @(negedge MemRead_EX) begin
    if(stall_from_hazard_unit) num_inst_reg = num_inst_reg + 1;
end

always @(inst_reg) begin
    if(inst_reg[15:12] == 4'd15 && inst_reg[5:0] == 6'd28 && MemRead_EX) num_inst_reg = num_inst_reg;
    else num_inst_reg = num_inst_reg + 1;
    
end

assign num_inst = num_inst_reg;

RF m_RF(
  .write(RegWrite_WB), .clk(clk), .reset_n(reset_n),
  .addr1(inst_reg[11:10]), .addr2(inst_reg[9:8]),
  .addr3(RF_write_addr),
  .data1(RF_result1), .data2(RF_result2),
  .data3(RF_write_data)
);

ALU m_ALU(
    .A(ALUin1), .B(ALUin2),
    .opcode(ALUOp_EX), .func(func_EX),
    .C(ALUOut)
);

Branch_Condition m_Branch_Condition(
    .ALUOp(ALUOp), .BranchSrc1(BranchSrc1),
    .BranchSrc2(BranchSrc2), .zero(zero)
);

Forwarding_Unit m_Forwarding_unit(
    .ID_rs(inst_reg[11:10]), .ID_rt(inst_reg[9:8]),
    .ID_EX_rs(ID_EX_rs), .ID_EX_rt(ID_EX_rt),
    .EX_rd_wire(EX_rd_wire), .EX_MEM_rd(EX_MEM_rd),
    .MEM_WB_rd(MEM_WB_rd),
    .RegWrite_EX(RegWrite_EX), .RegWrite_MEM(RegWrite_MEM),
    .RegWrite_WB(RegWrite_WB), .MemRead_EX(MemRead_EX), 

    .ForwardBr1(ForwardBr1),
    .ForwardBr2(ForwardBr2)
);

Branch_Predictor m_Branch_Predictor(
    .PC(PC), .zero(zero),
    .jump_PC(jump_PC), .IF_ID_PC(IF_ID_PC),
    .predicted_nextPC(branch_predicted_nextPC),
    .jump(jump), .unconditional_jump(unconditional_jump)
);

Hazard_Detection_Unit m_Hazard_Detection_Unit(
    .IF_ID_branch_predicted_nextPC(IF_ID_branch_predicted_nextPC),
    .jump_PC(jump_PC), .inst_reg(inst_reg),
    .PC(PC),
    .MemRead_EX(MemRead_EX), .EX_rd_wire(EX_rd_wire),
    .stall(stall_from_hazard_unit), .jump(jump), .MemRead(MemRead),
    .unconditional_jump(unconditional_jump)
);
reg i_readCache = 1;
reg i_writeCache = 0;
reg BG_0 = 0;

cache i_cache(
    .clk(clk), .readCache(i_readCache), .writeCache(i_writeCache),
    .address(i_address_to_cache), .address_to_memory(i_address),
    .data_between_cpu(i_data_between_cache),
    .data_between_memory(i_data),
    .readM(i_readM), .writeM(i_writeM), .stall(i_stall),
    .reset_n(reset_n), .BG(BG_0)
);

cache d_cache(
    .clk(clk), .readCache(MemRead_MEM), .writeCache(MemWrite_MEM),
    .address(d_address_to_cache), .address_to_memory(d_address),
    .data_between_cpu(d_data_between_cache),
    .data_between_memory(d_data),
    .readM(d_readM), .writeM(d_writeM), .stall(d_stall),
    .reset_n(reset_n), .BG(BG), .accessing_memory(accessing_memory)
);

endmodule