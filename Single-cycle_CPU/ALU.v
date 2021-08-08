`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/17 09:11:00
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define WORD_SIZE 16
`include "opcodes.v"

module ALU(
    input [`WORD_SIZE-1:0] A,
    input [`WORD_SIZE-1:0] B,
    input [3:0] opcode,
    input [5:0] func,
    output [`WORD_SIZE-1:0] C
    );
    reg [`WORD_SIZE-1:0] C;
always @(*) begin
    case(opcode)
        4'd15:begin
            case(func)
                6'd0 : C = A+B; // ADD
                // 6'd15:   // WWD
            endcase
        end
        `OPCODE_ADI : C = A+B; //ADI
        `OPCODE_LHI : C = B<<8; // LHI
        //`OPCODE_JMP : // JMP
        
    endcase
end

endmodule
