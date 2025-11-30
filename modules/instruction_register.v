module instruction_register (
    input [7:0] data_in, // data input bus
    input clk, // clock signal
    input ena, // enable signal
    input rst, // global reset
    output reg [1:0] mnm, // msb mnemonic field
    output reg [1:0] wr_addr_mnm, // lsb mnemonic or write address
    output reg [3:0] rd_addr_wr_data, // write data or read address
    output reg ack // end operation handshaking
);
   
always@(posedge clk or posedge rst) begin
    if(rst)
        begin
            mnm <= 2'b00;
            wr_addr_mnm <= 2'b00;
            rd_addr_wr_data <= 4'b0000;
        end
    else if(ena)
            begin
                mnm <= data_in[7:6];
                wr_addr_mnm <= data_in[5:4];
                rd_addr_wr_data <= data_in[3:0];
                if(data_in == {mnm,wr_addr_mnm,rd_addr_wr_data})
                    ack <= 1'b1;
            end
        else
            ack <= 1'b0;
 end     
endmodule