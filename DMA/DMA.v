`define WORD_SIZE 16
`define LINE_SIZE 64
/*************************************************
* DMA module (DMA.v)
* input: clock (CLK), bus request (BR) signal, 
*        data from the device (edata), and DMA command (cmd)
* output: bus grant (BG) signal 
*         READ signal
*         memory address (addr) to be written by the device, 
*         offset device offset (0 - 2)
*         data that will be written to the memory
*         interrupt to notify DMA is end
* You should NOT change the name of the I/O ports and the module name
* You can (or may have to) change the type and length of I/O ports 
* (e.g., wire -> reg) if you want 
* Do not add more ports! 
*************************************************/

module DMA (
    input CLK, BG,
    input [4 * `WORD_SIZE - 1 : 0] edata,
    input [`WORD_SIZE-1:0] cmd,
    output reg BR, 
    output READ,
    output [`WORD_SIZE - 1 : 0] addr, 
    output [4 * `WORD_SIZE - 1 : 0] data,
    output reg [1:0] offset,
    output reg interrupt);

    /* Implement your own logic */
reg [3:0] state;
reg [3:0] next_state;
initial begin
    state <= 0;
    next_state <= 0;
    interrupt = 0;
end

reg [`WORD_SIZE-1:0] cmd_addr;
reg [`WORD_SIZE-1:0] cmd_length;

always @(*) begin
    cmd_addr = {{4{1'b0}},cmd[11:0]};
    cmd_length = {{12{1'b0}},cmd[15:12]};
end

reg Write;
assign addr = Write ? cmd_addr : `WORD_SIZE'bz;
assign data = Write ? edata : `LINE_SIZE'bz;

assign READ = Write ? Write : 1'bz;


always @(*) begin
    if(cmd == `WORD_SIZE'hc1f4 && state == 0) begin
        BR = 1;
    end
end
always @(posedge CLK) begin
    state <= next_state;
end

always @(*) begin
    if(state != 0) next_state <= state + 1;
    else next_state <= 0;
end

always @(state, BG) begin
    case(state)
        0 : begin
            if(BG) next_state <= 1;
            else next_state <= 0;
        end
        1 : offset = 0;
        2 : Write = 1;
        3 : Write = 0;
        6 : begin
            offset = 1;
            cmd_addr = cmd_addr + 4;
        end
        7 : Write = 1;
        8 : Write = 0;
        11 : begin
            offset = 2;
            cmd_addr = cmd_addr + 4;
        end
        12 : Write = 1;
        13 : Write = 0;
        15 : BR = 0;
    endcase
end

//make interrupt pulse
always @(negedge BG) begin
    if(!interrupt) interrupt = 1;
end
always @(posedge CLK) begin
    if(interrupt) interrupt = 0;
end

endmodule


