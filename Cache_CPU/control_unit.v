`define WORD_SIZE 16
`include "opcodes.v"
module control_unit(
    input [`WORD_SIZE-1:0] inst,
    input stall,
    input clk,
    input i_stall,

    
    output reg [1:0] PCSrc,
    output reg ALUSrc,
    output reg [1:0] RegDst,
    output reg MemWrite,
    output reg MemRead,
    output reg MemtoReg,
    output reg LinkJump,
    output reg RegWrite,
    output reg is_halted,
    
    output [3:0] ALUOp,
    output [5:0] func
);

reg [1:0] PCSrc_temp;
reg ALUSrc_temp;
reg [1:0] RegDst_temp;
reg MemWrite_temp;
reg MemRead_temp;
reg MemtoReg_temp;
reg LinkJump_temp;
reg RegWrite_temp;


initial begin
    PCSrc = 2'dx;
    ALUSrc = 1'dx;
    RegDst = 2'dx;
    MemWrite = 1'd0;
    MemRead = 1'd0;
    MemtoReg = 1'd0;
    LinkJump = 1'dx;
    RegWrite = 1'd0;
    MemRead_temp = 1'd0;
    MemWrite_temp = 1'd0;
    RegWrite_temp = 1'd0;
end

assign ALUOp = inst[15:12];
assign func = inst[5:0];


always @(i_stall) begin
    if(i_stall) begin
        //MemRead_temp = MemRead;
        //MemWrite_temp = MemWrite;
        RegWrite_temp = RegWrite;
        //MemRead = 0;
        //MemWrite = 0;
        RegWrite = 0;
    end
    else begin
        //MemRead = MemRead_temp;
        //MemWrite = MemWrite_temp;
        RegWrite = RegWrite_temp;
        //MemRead_temp = 0;
        //MemWrite_temp = 0;
        RegWrite_temp = 0;
    end  
end

always @(ALUOp, func) begin
    if(!stall) begin
        case(ALUOp)
            4'd15 : begin
                case(func) 
                    `FUNC_ADD : begin
                        PCSrc = 2'dx;
                        ALUSrc = 1'd0;
                        RegDst = 2'd1;
                        MemWrite = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'd0;
                        LinkJump = 1'd0;
                        RegWrite = 1'd1;
                    end
                    `FUNC_SUB : begin
                        PCSrc = 2'dx;
                        ALUSrc = 1'd0;
                        RegDst = 2'd1;
                        MemWrite = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'd0;
                        LinkJump = 1'd0;
                        RegWrite = 1'd1;
                    end
                    `FUNC_AND : begin
                        PCSrc = 2'dx;
                        ALUSrc = 1'd0;
                        RegDst = 2'd1;
                        MemWrite = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'd0;
                        LinkJump = 1'd0;
                        RegWrite = 1'd1;
                    end
                    `FUNC_ORR : begin
                        PCSrc = 2'dx;
                        ALUSrc = 1'd0;
                        RegDst = 2'd1;
                        MemWrite = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'd0;
                        LinkJump = 1'd0;
                        RegWrite = 1'd1;
                    end
                    `FUNC_NOT : begin
                        PCSrc = 2'dx;
                        ALUSrc = 1'd0;
                        RegDst = 2'd1;
                        MemWrite = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'd0;
                        LinkJump = 1'd0;
                        RegWrite = 1'd1;
                    end
                    `FUNC_TCP : begin
                        PCSrc = 2'dx;
                        ALUSrc = 1'd0;
                        RegDst = 2'd1;
                        MemWrite = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'd0;
                        LinkJump = 1'd0;
                        RegWrite = 1'd1;
                    end
                    `FUNC_SHL : begin
                        PCSrc = 2'dx;
                        ALUSrc = 1'd0;
                        RegDst = 2'd1;
                        MemWrite = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'd0;
                        LinkJump = 1'd0;
                        RegWrite = 1'd1;
                    end
                    `FUNC_SHR : begin
                        PCSrc = 2'dx;
                        ALUSrc = 1'd0;
                        RegDst = 2'd1;
                        MemWrite = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'd0;
                        LinkJump = 1'd0;
                        RegWrite = 1'd1;
                    end
                    `FUNC_WWD : begin
                        PCSrc = 2'dx;
                        ALUSrc = 1'dx;
                        RegDst = 2'dx;
                        MemWrite = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'dx;
                        LinkJump = 1'dx;
                        RegWrite = 1'd0;
                    end
                    `FUNC_JPR : begin
                        PCSrc = 2'd2;
                        ALUSrc = 1'dx;
                        RegDst = 2'dx;
                        MemWrite = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'dx;
                        LinkJump = 1'dx;
                        RegWrite = 1'd0;
                    end
                    `FUNC_JRL : begin
                        PCSrc = 2'd2;
                        ALUSrc = 1'dx;
                        RegDst = 2'd2;
                        MemWrite = 1'd0;
                        MemRead = 1'd0;
                        MemtoReg = 1'dx;
                        LinkJump = 1'd1;
                        RegWrite = 1'd1;
                    end
                    `FUNC_HLT : is_halted = 1'd1;
                endcase
            end
            `OPCODE_ADI : begin
                PCSrc = 2'dx;
                ALUSrc = 1'd1;
                RegDst = 2'd0;
                MemWrite = 1'd0;
                MemRead = 1'd0;
                MemtoReg = 1'd0;
                LinkJump = 1'd0;
                RegWrite = 1'd1;
            end
            `OPCODE_ORI : begin
                PCSrc = 2'dx;
                ALUSrc = 1'd1;
                RegDst = 2'd0;
                MemWrite = 1'd0;
                MemRead = 1'd0;
                MemtoReg = 1'd0;
                LinkJump = 1'd0;
                RegWrite = 1'd1;
            end
            `OPCODE_LHI : begin
                PCSrc = 2'dx;
                ALUSrc = 1'd1;
                RegDst = 2'd0;
                MemWrite = 1'd0;
                MemRead = 1'd0;
                MemtoReg = 1'd0;
                LinkJump = 1'd0;
                RegWrite = 1'd1;
            end
            `OPCODE_LWD : begin
                PCSrc = 2'dx;
                ALUSrc = 1'd1;
                RegDst = 2'd0;
                MemWrite = 1'd0;
                MemRead = 1'd1;
                MemtoReg = 1'd1;
                LinkJump = 1'd0;
                RegWrite = 1'd1;
            end
            `OPCODE_SWD : begin
                PCSrc = 2'dx;
                ALUSrc = 1'd1;
                RegDst = 2'dx;
                MemWrite = 1'd1;
                MemRead = 1'd0;
                MemtoReg = 1'dx;
                LinkJump = 1'dx;
                RegWrite = 1'd0;
            end
            `OPCODE_BNE : begin
                PCSrc = 2'd0;
                ALUSrc = 1'dx;
                RegDst = 2'dx;
                MemWrite = 1'd0;
                MemRead = 1'd0;
                MemtoReg = 1'dx;
                LinkJump = 1'dx;
                RegWrite = 1'd0;
            end
            `OPCODE_BEQ : begin
                PCSrc = 2'd0;
                ALUSrc = 1'dx;
                RegDst = 2'dx;
                MemWrite = 1'd0;
                MemRead = 1'd0;
                MemtoReg = 1'dx;
                LinkJump = 1'dx;
                RegWrite = 1'd0;
            end
            `OPCODE_BGZ : begin
                PCSrc = 2'd0;
                ALUSrc = 1'dx;
                RegDst = 2'dx;
                MemWrite = 1'd0;
                MemRead = 1'd0;
                MemtoReg = 1'dx;
                LinkJump = 1'dx;
                RegWrite = 1'd0;
            end
            `OPCODE_BLZ : begin
                PCSrc = 2'd0;
                ALUSrc = 1'dx;
                RegDst = 2'dx;
                MemWrite = 1'd0;
                MemRead = 1'd0;
                MemtoReg = 1'dx;
                LinkJump = 1'dx;
                RegWrite = 1'd0;
            end
            `OPCODE_JMP : begin
                PCSrc = 2'd1;
                ALUSrc = 1'dx;
                RegDst = 2'dx;
                MemWrite = 1'd0;
                MemRead = 1'd0;
                MemtoReg = 1'dx;
                LinkJump = 1'dx;
                RegWrite = 1'd0;
            end
            `OPCODE_JAL : begin
                PCSrc = 2'd1;
                ALUSrc = 1'dx;
                RegDst = 2'd2;
                MemWrite = 1'd0;
                MemRead = 1'd0;
                MemtoReg = 1'd0;
                LinkJump = 1'd1;
                RegWrite = 1'd1;
            end
        endcase
    end
    else begin
        if(ALUOp == `OPCODE_JAL) begin
            PCSrc = 2'd1;
            ALUSrc = 1'dx;
            RegDst = 2'd2;
            MemWrite = 1'd0;
            MemRead = 1'd0;
            MemtoReg = 1'd0;
            LinkJump = 1'd1;
            RegWrite = 1'd1;
        end
        else if(ALUOp == 4'd15 && func == `FUNC_JRL) begin
            PCSrc = 2'd2;
            ALUSrc = 1'dx;
            RegDst = 2'd2;
            MemWrite = 1'd0;
            MemRead = 1'd0;
            MemtoReg = 1'dx;
            LinkJump = 1'd1;
            RegWrite = 1'd1;
        end
        else begin
            //PCSrc = 2'dx;
            ALUSrc = 1'dx;
            RegDst = 2'dx;
            //MemWrite = 1'd0;
            //MemRead = 1'd0;
            MemtoReg = 1'd0;
            LinkJump = 1'dx;
            RegWrite = 1'd0;
        end
    end
end


endmodule
