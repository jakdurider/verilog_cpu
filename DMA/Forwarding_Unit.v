module Forwarding_Unit(
    input [1:0] ID_rs,
    input [1:0] ID_rt,
    input [1:0] ID_EX_rs,
    input [1:0] ID_EX_rt,
    input [1:0] EX_rd_wire,
    input [1:0] EX_MEM_rd,
    input [1:0] MEM_WB_rd,
    
    input RegWrite_EX,
    input RegWrite_MEM,
    input RegWrite_WB,
    input MemRead_EX,
   
    
    output reg [1:0] ForwardBr1,
    output reg [1:0] ForwardBr2
);

// ForwardBr1
always @(*) begin
    if(ID_rs == EX_rd_wire && RegWrite_EX && !MemRead_EX) ForwardBr1 = 2'd1;
    else if(ID_rs == EX_MEM_rd && RegWrite_MEM) ForwardBr1 = 2'd2;
    else if(ID_rs == MEM_WB_rd && RegWrite_WB) ForwardBr1 = 2'd3;
    else ForwardBr1 = 2'd0;
end



// ForwardBr2
always @(*) begin
    if(ID_rt == EX_rd_wire && RegWrite_EX && !MemRead_EX) ForwardBr2 = 2'd1;
    else if(ID_rt == EX_MEM_rd && RegWrite_MEM) ForwardBr2 = 2'd2;
    else if(ID_rt == MEM_WB_rd && RegWrite_WB) ForwardBr2 = 2'd3;
    else ForwardBr2 = 2'd0;
end
endmodule
