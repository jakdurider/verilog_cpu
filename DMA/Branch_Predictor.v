`define WORD_SIZE 16
`define index_bit 4
`define NUM_LINE 16

module Branch_Predictor(
  input [`WORD_SIZE-1:0] PC,
  input zero,
  input [`WORD_SIZE-1:0] jump_PC,
  input [`WORD_SIZE-1:0] IF_ID_PC,
  input jump,
  input unconditional_jump,
  output reg [`WORD_SIZE-1:0] predicted_nextPC
);

reg [`WORD_SIZE-`index_bit-1:0] tag_table[`NUM_LINE-1:0];
reg [1:0] prediction_state[`NUM_LINE-1:0];
reg [`WORD_SIZE-1:0] jump_PC_table[`NUM_LINE-1:0];

wire [`index_bit-1:0] index = PC[`index_bit-1:0];
wire [`index_bit-1:0] update_index = IF_ID_PC[`index_bit-1:0];

integer i;
//initialize
initial begin
    for(i = 0; i<`NUM_LINE ; i=i+1) begin
        tag_table[i] <= 0;
        prediction_state[i] <= 0;
        jump_PC_table[i] <= 1;
    end
end

// read prediction_table
always @(PC) begin
    if(PC[15:`index_bit] == tag_table[index]) begin
        if(prediction_state[index] >= 2) predicted_nextPC = jump_PC_table[index];
        else predicted_nextPC = PC + 1;
    end
    else predicted_nextPC = PC + 1;
end

// update
always @(posedge jump) begin
    if(IF_ID_PC[15:`index_bit] == tag_table[update_index]) begin     // tag matched
        if(unconditional_jump && prediction_state[update_index] < 3) begin
            prediction_state[update_index] <= prediction_state[update_index] + 1;
        end
        else if(zero && prediction_state[update_index] < 3) begin 
            prediction_state[update_index] <= prediction_state[update_index] + 1;
        end
        else if(!zero && prediction_state[update_index] > 0) begin
            prediction_state[update_index] <= prediction_state[update_index] - 1;
        end
    end
    else begin  // tag unmatched
        tag_table[update_index] = IF_ID_PC[15:`index_bit];
        jump_PC_table[update_index] = jump_PC;
        prediction_state[update_index] = 2'd2;
    end
end

always @(negedge jump) begin
    if(IF_ID_PC[15:`index_bit] == tag_table[update_index]) begin     // tag matched
        if(!zero && prediction_state[update_index] > 0) begin
            prediction_state[update_index] <= prediction_state[update_index] - 1;
        end
    end
end

endmodule