module ula_4bit_sync (
    input  wire        clk,         // clock
    input  wire        enable,      // enable signal
    input  wire [3:0]  a,           // operand A
    input  wire [3:0]  b,           // operand B
    input  wire [3:0]  sel,         // operation selector
    output reg  [3:0]  result,      // ALU result
    output reg         ula_ack      // handshake: goes high for 1 cycle
);

    always @(posedge clk) begin
        if (enable) begin
            casex (sel)
                4'b0100: result <= a | b;
                4'b0101: result <= a & b;
                4'b0110: result <= a ^ b;
                4'b0111: result <= ~(a & b);
                4'b10xx: result <= a + b;
                4'b11xx: result <= a - b;
                default: result <= 4'b0000;
            endcase
            ula_ack <= 1'b1;  // end of operation
        end else begin
            ula_ack <= 1'b0;  // hasn't operated
        end
    end

endmodule
