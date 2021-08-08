`define WORD_SIZE 16
`define NUM_REG 4
module RF(
  input write,
  input clk,
  input reset_n,
  input [1:0] addr1,
  input [1:0] addr2,
  input [1:0] addr3,
  output [`WORD_SIZE-1:0] data1,
  output [`WORD_SIZE-1:0] data2,
  input [`WORD_SIZE-1:0] data3
);

reg [`WORD_SIZE-1:0] regs[`NUM_REG-1:0];

//combinational read
assign data1 = regs[addr1];
assign data2 = regs[addr2];

always @(negedge reset_n) begin
  regs[0]<=0;
  regs[1]<=0;
  regs[2]<=0;
  regs[3]<=0;
end

always @(posedge clk) begin
  if(write==1) begin
    regs[addr3] <= data3;
  end
end

endmodule