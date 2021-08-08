`include "cache_state.v"
`define NUM_LINE 4
`define NUM_WORD_PER_LINE 4
`define TAG_SIZE 12
`define INDEX_SIZE 2
`define BO_SIZE 2
`define WORD_SIZE 16
`define LINE_SIZE 64
module cache(
    input clk,
    input reset_n,
    input readCache,
    input writeCache,
    input [`WORD_SIZE-1:0] address,
    output reg [`WORD_SIZE-1:0] address_to_memory,
    inout [`WORD_SIZE-1:0] data_between_cpu,
    inout [`LINE_SIZE-1:0] data_between_memory,
    output reg readM,
    output reg writeM,
    output reg stall
    );
    /*
//just memory
reg state;
reg next_state;
reg next_stall;
always @(posedge clk) begin
    if(reset_n) state <= next_state;
end
always @(negedge clk) begin
    if(reset_n) stall <= next_stall;
end

initial begin
    state <= 0;
    next_state <= 0;
    stall <= 0;
    next_stall <= 0;
end

always @(*) begin
    if(next_state) next_stall = 1;
    else next_stall = 0;
end

always @(*) begin
    case(state)
        1'b0 : begin
            readM = 0;
            writeM = 0;
            if(readCache) begin
                next_state = 1;
                readM = 1;
            end
            else if(writeCache) begin
                next_state = 1;
                writeM = 1;
            end
        end
        1'b1 : begin
            next_state = 0;
        end
    endcase 
end

assign data_between_cpu = readM ? data_between_memory : `LINE_SIZE'bz;
assign data_between_memory = writeM ? data_between_cpu : `LINE_SIZE'bz;
always @(*) begin
    address_to_memory = address;
end 

*/




reg [`TAG_SIZE-1:0] tags[`NUM_LINE-1:0];
reg dirty_bits[`NUM_LINE-1:0];
reg [`WORD_SIZE-1:0] datas[`NUM_LINE-1:0][`NUM_WORD_PER_LINE-1:0];

wire [`TAG_SIZE-1:0] tag = address[`WORD_SIZE-1:`WORD_SIZE-`TAG_SIZE];
wire [`INDEX_SIZE-1:0] index = address[`WORD_SIZE-`TAG_SIZE-1:`WORD_SIZE-`TAG_SIZE-`INDEX_SIZE];
wire [`BO_SIZE-1:0] bo = address[`WORD_SIZE-`TAG_SIZE-`INDEX_SIZE-1:0];

reg [4:0] state;
reg [4:0] next_state;
reg next_stall;


reg [`WORD_SIZE-1:0] i;
initial begin
    state <= `INITIAL_STATE;
    next_state <= `R_S0;
    stall <= 0;
    next_stall <= 0;
    readM <= 0;
    writeM <= 0;
    for(i=0;i<`NUM_LINE;i=i+1) begin
        tags[i] <= -1;
        dirty_bits[i] <= 0;
    end
end



always @(posedge clk) begin
    if(reset_n) begin
        state <= next_state;
    end
end
always @(negedge clk) begin
    if(reset_n) begin
        stall <= next_stall;
    end
end

always @(next_state) begin
    if(next_state == `INITIAL_STATE) next_stall = 0;
    else next_stall = 1;
end

reg [`WORD_SIZE-1:0] OutputData_to_cpu;
reg [`LINE_SIZE-1:0] OutputData_to_memory;
assign data_between_cpu = readCache ? OutputData_to_cpu : 16'bz;
assign data_between_memory = state == `R_S5 || state == `W_S5 ? OutputData_to_memory : `LINE_SIZE'bz;

// Read State
always @(*) begin
    case(state)
        `INITIAL_STATE : begin
            readM = 0;
            writeM = 0;
            if(readCache) begin
                if(tags[index] == tag) begin
                    next_state = `INITIAL_STATE;
                    OutputData_to_cpu = datas[index][bo];
                end
                else begin
                    next_state = `R_S0;
                end
            end
        end
        `R_S0 : begin
            if(dirty_bits[index]) next_state = `R_S5;
            else next_state = `R_S1;
        end
        `R_S1 : begin
            next_state = `R_S2;
            address_to_memory = address;
            readM = 1;
        end
        `R_S2 : next_state = `R_S3;
        `R_S3 : next_state = `R_S4;
        `R_S4 : begin
            next_state = `INITIAL_STATE;
            datas[index][0] = data_between_memory[15:0];
            datas[index][1] = data_between_memory[31:16];
            datas[index][2] = data_between_memory[47:32];
            datas[index][3] = data_between_memory[63:48];
            tags[index] = tag;
            dirty_bits[index] = 1'b0;
            OutputData_to_cpu = datas[index][bo];
        end
        `R_S5 : begin
            next_state = `R_S6;
            OutputData_to_memory = {datas[index][3],datas[index][2],datas[index][1],datas[index][0]};
            writeM = 1;
        end
        `R_S6 : begin
            next_state = `R_S7;
            writeM = 0;
        end
        `R_S7 : next_state = `R_S8;
        `R_S8 : begin
            next_state = `R_S1;
            writeM = 0;
        end
    endcase
end

// Write State
always @(data_between_cpu) begin
    case(state)
        `INITIAL_STATE : begin
            if(writeCache) begin
                if(tags[index] == tag) begin
                    datas[index][bo] = data_between_cpu;
                    dirty_bits[index] = 1'b1;
                end
            end
        end
    endcase
end

always @(*) begin
    case(state)
        `INITIAL_STATE : begin
            readM = 0;
            writeM = 0;
            if(writeCache) begin
                if(tags[index] == tag) begin
                    next_state = `INITIAL_STATE;
                end
                else begin
                    next_state = `W_S0;
                end
            end
        end
        `W_S0 : begin
            if(dirty_bits[index]) next_state = `W_S5;
            else next_state = `W_S1;
        end
        `W_S1 : begin
            next_state = `W_S2;
            address_to_memory = address;
            readM = 1;
        end
        `W_S2 : next_state = `W_S3;
        `W_S3 : next_state = `W_S4;
        `W_S4 : begin
            next_state = `INITIAL_STATE;
            datas[index][0] = data_between_memory[15:0];
            datas[index][1] = data_between_memory[31:16];
            datas[index][2] = data_between_memory[47:32];
            datas[index][3] = data_between_memory[63:48];
            tags[index] = tag;
            dirty_bits[index] = 1'b1;
            datas[index][bo] = data_between_cpu;
        end
        `W_S5 : begin
            next_state = `W_S6;
            address_to_memory = {tags[index],index,2'b00};
            OutputData_to_memory = {datas[index][3],datas[index][2],datas[index][1],datas[index][0]};
            writeM = 1;
        end
        `W_S6 : begin
            next_state = `W_S7;
            writeM = 0;
        end
        `W_S7 : next_state = `W_S8;
        `W_S8 : begin
            next_state = `W_S1;
            writeM = 0;
        end
    endcase
end

endmodule

