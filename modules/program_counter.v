module program_counter (
    input  wire        clk,
    input  wire        rst,
    input  wire        en,
    output reg  [7:0]  pc_out,
    output reg         ack      // new handshaking singal
);

    always @(negedge clk or negedge rst) begin
        if (!rst) begin
            pc_out <= 8'b0;
            ack    <= 1'b0;
        end else if (en) begin
            pc_out <= pc_out + 1;
            ack    <= 1'b1;     // high for 1 cycle when counting
        end else begin
            ack    <= 1'b0;     // ack low when not counting in other cycles
        end
    end

endmodule
