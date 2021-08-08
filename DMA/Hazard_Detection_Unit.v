`define WORD_SIZE 16
module Hazard_Detection_Unit(
  input [`WORD_SIZE-1:0] IF_ID_branch_predicted_nextPC,
  input [`WORD_SIZE-1:0] jump_PC,
  input [`WORD_SIZE-1:0] inst_reg,
  input MemRead_EX,
  input [`WORD_SIZE-1:0] PC,
  input [1:0] EX_rd_wire,
  input MemRead,
  
  output reg stall,
  output reg jump,
  output reg unconditional_jump
);
wire [3:0] ALUOp = inst_reg[15:12];
wire [5:0] func = inst_reg[5:0];
wire [1:0] rs = inst_reg[11:10];
wire [1:0] rt = inst_reg[9:8];
reg use_rs;
reg use_rt;

// use_rs logic
always @(*) begin
    if(ALUOp==4'd6 || ALUOp==4'd9 || ALUOp == 4'd10) use_rs = 0;
    else use_rs = 1;
end

// use_rt logic
always @(*) begin
    if(ALUOp == 4'd15) begin
        if(func==6'd0 || func==6'd1 || func==6'd2 || func==6'd3) use_rt = 1;
        else use_rt = 0;
    end
    else if(ALUOp == 4'd0 || ALUOp == 4'd1 || ALUOp == 4'd8) use_rt = 1;
    else use_rt = 0;
end

initial begin
  stall = 0;
  use_rs = 0;
  use_rt = 0;
  jump = 0;
end

// to judge whether this is control transfer instruction
//reg jump;
always @(*) begin
    if(ALUOp >= 4'd0 && ALUOp <= 4'd3) jump = 1;
    else if(ALUOp == 4'd9 || ALUOp == 4'd10) jump = 1;
    else if(ALUOp == 4'd15) begin
        if(func == 6'd25 || func == 6'd26) jump = 1;
        else jump = 0;
    end
    else jump = 0;
end

always @(*) begin
    if(ALUOp ==4'd9 || ALUOp == 4'd10) unconditional_jump = 1;
    else if(ALUOp == 4'd15) begin
        if(func == 6'd25 || func == 6'd26) unconditional_jump = 1;
        else unconditional_jump = 0;
    end
    else unconditional_jump = 0;
end

//data hazard and control hazard
always @(*) begin
    //data hazard
    
    if(MemRead_EX && EX_rd_wire == rs && use_rs) stall = 1;
    else if(MemRead_EX && EX_rd_wire == rt && use_rt) stall = 1;
   
    else begin
        //control hazard
        if(jump_PC != IF_ID_branch_predicted_nextPC && jump) stall = 1;
        if(jump_PC == PC || !jump) stall = 0;
        
    end
end


endmodule