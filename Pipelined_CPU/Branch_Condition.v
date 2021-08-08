`define WORD_SIZE 16
`include "opcodes.v"

module Branch_Condition(
    input [3:0] ALUOp,
    input [`WORD_SIZE-1:0] BranchSrc1,
    input [`WORD_SIZE-1:0] BranchSrc2,
    output reg zero
);

always @(*) begin
    case(ALUOp)
        `OPCODE_BNE : begin
            if(BranchSrc1!=BranchSrc2) zero = 1;
            else zero = 0;
        end
        `OPCODE_BEQ : begin
            if(BranchSrc1==BranchSrc2) zero = 1;
            else zero = 0;
        end
        `OPCODE_BGZ : begin
            if(BranchSrc1 > 0 && BranchSrc1[`WORD_SIZE-1] == 0) zero = 1;
            else zero = 0;
        end
        `OPCODE_BLZ : begin
            if(BranchSrc1[`WORD_SIZE-1] == 1) zero = 1;
            else zero = 0;
        end
        default : zero = 0;
    endcase
end

endmodule