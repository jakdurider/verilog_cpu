`define WORD_SIZE 16
`include "opcodes.v"
module ALU(
    input [`WORD_SIZE-1:0] A,
    input [`WORD_SIZE-1:0] B,
    input [3:0] opcode,
    input [5:0] func,
    output reg [`WORD_SIZE-1:0] C
);

always @(*) begin
    case(opcode)
        4'd15 : begin
            case(func)
                `FUNC_ADD : C = A+B;
                `FUNC_SUB : C = A-B;
                `FUNC_AND : C = A&B;
                `FUNC_ORR : C = A|B;
                `FUNC_NOT : C = ~A;
                `FUNC_TCP : C = ~A+1;
                `FUNC_SHL : C = A<<1;
                `FUNC_SHR : C = {A[`WORD_SIZE-1],A[`WORD_SIZE-1:1]};
                //`FUNC_WWD
                //`FUNC_JPR
                //`FUNC_JRL
                //`FUNC_HLT
            endcase
        end
        `OPCODE_ADI : C = A+B;
        `OPCODE_ORI : C = A|{{8'b0},B[7:0]};
        `OPCODE_LHI : C = B<<8;
        `OPCODE_LWD : C = A+B;
        `OPCODE_SWD : C = A+B;
    endcase
end

endmodule