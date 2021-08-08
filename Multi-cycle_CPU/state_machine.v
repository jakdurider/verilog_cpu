`define WORD_SIZE 16
`include "opcodes.v"
`include "state_constants.v"

module state_machine(
    input [`WORD_SIZE-1:0] inst,
    input clk,
    input reset_n,
    output reg [3:0] state
);
    reg [3:0] next_state;
    
    wire [3:0] ALUOp;
    wire [5:0] func;
    assign ALUOp = inst[15:12];
    assign func = inst[5:0];
    initial begin
        state <= `First;
        next_state <= `IF;
    end
    
    always @(posedge clk) begin
        if(reset_n) state <= next_state;
    end
    
    always @(*) begin
        case(state)
            `First : next_state <= `IF;
            `IF : next_state <= `ID;
            `ID : begin
                case(ALUOp)
                    4'd15 : begin
                        if(func==`FUNC_WWD || func == `FUNC_JPR || func == `FUNC_JRL || func == `FUNC_HLT) next_state <= `IF;
                        else next_state <= `R_type_EX;
                    end
                    `OPCODE_ADI : next_state <= `I_type_EX;
                    `OPCODE_ORI : next_state <= `I_type_EX;
                    `OPCODE_LHI : next_state <= `I_type_EX;
                    `OPCODE_LWD : next_state <= `Load_EX;
                    `OPCODE_SWD : next_state <= `Store_EX;
                    `OPCODE_BNE : next_state <= `Branch_EX;
                    `OPCODE_BEQ : next_state <= `Branch_EX;
                    `OPCODE_BGZ : next_state <= `Branch_EX;
                    `OPCODE_BLZ : next_state <= `Branch_EX;
                    `OPCODE_JMP : next_state <= `IF;
                    `OPCODE_JAL : next_state <= `IF;
                endcase
            end
            
            `R_type_EX : next_state <= `R_type_WB;
            `I_type_EX : next_state <= `I_type_WB;
            `Branch_EX : next_state <= `IF;
            `Store_EX : next_state <= `Store_MEM;
            `Load_EX : next_state <= `Load_MEM;
            
            `Store_MEM : next_state <= `IF;
            `Load_MEM : next_state <= `Load_WB;
            
            `R_type_WB : next_state <= `IF;
            `I_type_WB : next_state <= `IF;
            `Load_WB : next_state <= `IF;
        endcase    
    end 
endmodule