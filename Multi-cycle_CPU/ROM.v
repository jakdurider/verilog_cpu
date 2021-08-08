`define WORD_SIZE 16
`include "opcodes.v"
`include "state_constants.v"

module ROM(
    input [3:0] state,
    input [`WORD_SIZE-1:0] inst,
    
    output reg PCWriteCond,
    output reg PCWrite,
    output reg IorD,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg IRWrite,
    output reg [1:0] PCSource,
    output reg [1:0] ALUSrcB,
    output reg ALUSrcA,
    output reg RegWrite,
    output reg [1:0] RegDst,
    
    output reg [3:0] ALUOp,
    output reg [5:0] func,
    
    output reg is_halted
);
   
    always @(*) begin
        case(state)
            `IF : begin     // needs initialization and instruction read
                PCWrite = 1'b1; // PC<=PC+1 at next posedge clk
                PCWriteCond = 1'b0;
                IorD= 1'b0;
                MemRead = 1'b1;
                //MemRead = 1'b0; // make readM 0 again
                MemWrite = 1'b0;
                MemtoReg = 1'bx;
                IRWrite = 1'b1; // ID stage needs register read in next posedge clk
                PCSource = 2'b00;
                ALUSrcB = 2'b01;
                ALUSrcA = 1'b0;
                RegWrite = 1'b0;
                RegDst = 2'bxx;
                ALUOp = `OPCODE_ADI;
                func = 6'dx;
            end
            `ID : begin
                case(inst[15:12])
                    4'd15 : begin
                        case(inst[5:0])
                            `FUNC_JPR : begin
                                PCWrite = 1'b1;
                                PCWriteCond = 1'b0;
                                IorD = 1'b0;
                                MemRead = 1'b0;
                                MemWrite = 1'b0;
                                MemtoReg = 1'bx;
                                IRWrite = 1'b0;
                                PCSource = 2'b11;
                                ALUSrcB = 2'bxx;
                                ALUSrcA = 1'bx;
                                RegWrite = 1'b0;
                                RegDst = 2'bxx;
                                ALUOp = 4'dx;
                                func = 6'dx;
                            end
                            `FUNC_JRL : begin
                                PCWrite = 1'b1;
                                PCWriteCond = 1'b0;
                                IorD = 1'b0;
                                MemRead = 1'b0;
                                MemWrite = 1'b0;
                                MemtoReg = 1'b0;    // put next instruction to reg[2]
                                IRWrite = 1'b0;
                                PCSource = 2'b11;
                                ALUSrcB = 2'bxx;
                                ALUSrcA = 1'bx;
                                RegWrite = 1'b1;    // put next instruction to reg[2]
                                RegDst = 2'b10;     // put next instruction to reg[2]
                                ALUOp = 4'dx;
                                func = 6'dx;
                            end
                            `FUNC_HLT : is_halted = 1'b1; // need just halt signal
                            `FUNC_WWD : begin
                                PCWrite = 1'b0;
                                PCWriteCond = 1'b0;
                                IorD = 1'b0;
                                MemRead = 1'b0;
                                MemWrite = 1'b0;
                                MemtoReg = 1'bx;
                                IRWrite = 1'b0;
                                PCSource = 2'bxx;
                                ALUSrcB = 2'bxx;
                                ALUSrcA = 1'bx;
                                RegWrite = 1'b0;
                                RegDst = 2'bxx;
                                ALUOp = 4'd15;
                                func = `FUNC_WWD;
                            end
                            default : begin // R_type calculation
                                PCWrite = 1'b0;
                                PCWriteCond = 1'b0;
                                IorD = 1'b0;
                                MemRead = 1'b0;
                                MemWrite = 1'b0;
                                MemtoReg = 1'bx;
                                IRWrite = 1'b0;
                                PCSource = 2'bxx;
                                ALUSrcB = 2'bxx;
                                ALUSrcA = 1'bx;
                                RegWrite = 1'b0;
                                RegDst = 2'bxx;
                                ALUOp = 4'dx;
                                func = 6'dx;
                            end
                        endcase
                    end
                    `OPCODE_JMP : begin
                        PCWrite = 1'b1;
                        PCWriteCond = 1'b0;
                        IorD = 1'b0;
                        MemRead = 1'b0;
                        MemWrite = 1'b0;
                        MemtoReg = 1'bx;
                        IRWrite = 1'b0;
                        PCSource = 2'b10;   //next pc is target
                        ALUSrcB = 2'bxx;
                        ALUSrcA = 1'bx;
                        RegWrite = 1'b0;
                        RegDst = 2'bxx;
                        ALUOp = 4'dx;
                        func = 6'dx;
                    end
                    `OPCODE_JAL : begin
                        PCWrite = 1'b1;
                        PCWriteCond = 1'b0;
                        IorD = 1'b0;
                        MemRead = 1'b0;
                        MemWrite = 1'b0;
                        MemtoReg = 1'b0;    // write next inst to reg[2]
                        IRWrite = 1'b0;
                        PCSource = 2'b10;   //next pc is target
                        ALUSrcB = 2'bxx;
                        ALUSrcA = 1'bx;
                        RegWrite = 1'b1;    // put next inst to reg[2]
                        RegDst = 2'b10;     // put next inst to reg[2]
                        ALUOp = 4'dx;
                        func = 6'dx;
                    end
                    default : begin     // I_type, Branch, Store, Load
                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        IorD = 1'b0;
                        MemRead = 1'b0;
                        MemWrite = 1'b0;
                        MemtoReg = 1'bx;    
                        IRWrite = 1'b0;
                        PCSource = 2'bxx;   
                        ALUSrcB = 2'b10;    // include branch so make ALUSrc match with branch
                        ALUSrcA = 1'b0;     // include branch so make ALUSrc match with branch
                        RegWrite = 1'b0;    
                        RegDst = 2'bxx;     
                        ALUOp = `OPCODE_ADI; // include branch so make ALUSrc match with branch
                        func = 6'dx;
                    end
                endcase
            end
            
            `R_type_EX : begin
                PCWrite = 1'b0;
                PCWriteCond = 1'b0;
                IorD = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'bx;
                IRWrite = 1'b0;
                PCSource = 2'bxx;
                ALUSrcB = 2'b00;    // ALUSrcB is register result
                ALUSrcA = 1'b1;
                RegWrite = 1'b0;
                RegDst = 2'bxx;
                ALUOp = inst[15:12];
                func = inst[5:0];
            end
            `I_type_EX : begin
                PCWrite = 1'b0;
                PCWriteCond = 1'b0;
                IorD = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'bx;
                IRWrite = 1'b0;
                PCSource = 2'bxx;
                ALUSrcB = 2'b10;    // ALUSrcB is immediate
                ALUSrcA = 1'b1;
                RegWrite = 1'b0;
                RegDst = 2'bxx;
                ALUOp = inst[15:12];
                func = inst[5:0];
            end
            `Branch_EX : begin
                PCWrite = 1'b0;
                PCWriteCond = 1'b1; // conditional pc write
                IorD = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'bx;
                IRWrite = 1'b0;
                PCSource = 2'b01;   // ALUOut becomes PC if condition met
                ALUSrcB = 2'b00;    
                ALUSrcA = 1'b1;
                RegWrite = 1'b0;
                RegDst = 2'bxx;
                ALUOp = inst[15:12];
                func = inst[5:0];
            end
            
            `Store_EX : begin
                PCWrite = 1'b0;
                PCWriteCond = 1'b0;
                IorD = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'bx;
                IRWrite = 1'b0;
                PCSource = 2'bxx;
                ALUSrcB = 2'b10;    // address needs immediate
                ALUSrcA = 1'b1;
                RegWrite = 1'b0;
                RegDst = 2'bxx;
                ALUOp = inst[15:12];
                func = inst[5:0];
            end
            `Load_EX : begin
                PCWrite = 1'b0;
                PCWriteCond = 1'b0;
                IorD = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'bx;
                IRWrite = 1'b0;
                PCSource = 2'bxx;
                ALUSrcB = 2'b10;    // address needs immediate
                ALUSrcA = 1'b1;
                RegWrite = 1'b0;
                RegDst = 2'bxx;
                ALUOp = inst[15:12];
                func = inst[5:0];
            end
            
            `Store_MEM : begin
                PCWrite = 1'b0;
                PCWriteCond = 1'b0;
                IorD = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b1;    // write to memory
                //MemWrite = 1'b0;    // make writeM == 0 again
                MemtoReg = 1'bx;
                IRWrite = 1'b0;
                PCSource = 2'bxx;
                ALUSrcB = 2'bxx;    
                ALUSrcA = 1'bx;
                RegWrite = 1'b0;
                RegDst = 2'bxx;
                ALUOp = 4'dx;
                func = 6'dx;
            end
            `Load_MEM : begin
                PCWrite = 1'b0;
                PCWriteCond = 1'b0;
                IorD = 1'b1;
                MemRead = 1'b1; // read memory
                //MemRead = 1'b0; // make readM == 0 again
                MemWrite = 1'b0;
                MemtoReg = 1'bx;
                IRWrite = 1'b0;
                PCSource = 2'bxx;
                ALUSrcB = 2'bxx;    
                ALUSrcA = 1'bx;
                RegWrite = 1'b0;
                RegDst = 2'bxx;
                ALUOp = 4'dx;
                func = 6'dx;
            end
            
            `R_type_WB : begin
                PCWrite = 1'b0;
                PCWriteCond = 1'b0;
                IorD = 1'b0;
                MemRead = 1'b0; 
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                IRWrite = 1'b0;
                PCSource = 2'bxx;
                ALUSrcB = 2'bxx;    
                ALUSrcA = 1'bx;
                RegWrite = 1'b1;    // write to register
                RegDst = 2'b01;     // destination reg : rd 
                ALUOp = 4'dx;
                func = 6'dx;
            end
            `I_type_WB : begin
                PCWrite = 1'b0;
                PCWriteCond = 1'b0;
                IorD = 1'b0;
                MemRead = 1'b0; 
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                IRWrite = 1'b0;
                PCSource = 2'bxx;
                ALUSrcB = 2'bxx;    
                ALUSrcA = 1'bx;
                RegWrite = 1'b1;    // write to register
                RegDst = 2'b00;     // destination reg : rt
                ALUOp = 4'dx;
                func = 6'dx;
            end
            `Load_WB : begin
                PCWrite = 1'b0;
                PCWriteCond = 1'b0;
                IorD = 1'b0;
                MemRead = 1'b0; 
                MemWrite = 1'b0;
                MemtoReg = 1'b1;
                IRWrite = 1'b0;
                PCSource = 2'bxx;
                ALUSrcB = 2'bxx;    
                ALUSrcA = 1'bx;
                RegWrite = 1'b1;    // write to register
                RegDst = 2'b00;     // destination reg : rt
                ALUOp = 4'dx;
                func = 6'dx;
            end
        endcase
    end

endmodule