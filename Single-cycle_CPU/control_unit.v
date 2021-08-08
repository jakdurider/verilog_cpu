`define WORD_SIZE 16
`include "opcodes.v"

module control_unit(
    input [`WORD_SIZE-1:0] inst,
    
    output reg RegDst,
    output reg Jump,
    output reg Branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite,
    
    output [3:0] ALUOp,
    output [5:0] func
);
    assign ALUOp = inst[15:12];
    assign func = inst[5:0];
    initial begin
        Jump = 0;
        Branch = 0;
    end
    always @(inst) begin
        case(inst[15:12])
            4'd15:begin
                case(inst[5:0])
                    `FUNC_ADD : begin
                        RegDst = 1;
                        Jump = 0;
                        Branch = 0;
                        MemRead = 0;
                        MemtoReg = 0;
                        MemWrite = 0;
                        ALUSrc = 0;
                        RegWrite = 1;
                    end
                    `FUNC_WWD : begin
                        RegDst = 0;
                        Jump = 0;
                        Branch = 0;
                        MemRead = 0;
                        MemtoReg = 0;
                        MemWrite = 0;
                        ALUSrc = 0;
                        RegWrite = 0;
                    end
                endcase
            end
            `OPCODE_ADI:begin
                RegDst = 0;
                Jump = 0;
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUSrc = 1;
                RegWrite = 1;
            end
            `OPCODE_LHI:begin
                RegDst = 0;
                Jump = 0;
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUSrc = 1;
                RegWrite = 1;
            end
            `OPCODE_JMP:begin
                RegDst = 0;
                Jump = 1;
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUSrc = 1;
                RegWrite = 0;
            end
        endcase
    end

endmodule