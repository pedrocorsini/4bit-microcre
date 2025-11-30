module fsm(
	input wire [1:0] 	mnm_in,			// instruction mnmonic field
	input wire 			clk,			// clock
	input wire 			rst,			// global reset
	input wire 			ula_ack,		// end alu handshaking
	input wire			wr_ack,			// end register bank handshaking 
	input wire			pc_ack,			// end program counter handshaking 
	input wire 			ri_ack,			// end instruction register handshaking
	output reg			ena_pc,			// enables program counter
	output reg 			ena_ri,			// enables instruction register
	output reg 			ena_wr,			// enabels bank writing 
	output reg 			sel_r0_rd,		// bank writing address selection
	output reg 			sel_addr_data,	// data or address selection
	output reg			sel_ldr_ula,	// data bank selection
	output reg			ena_ula,		// enables alu
	output [2:0] 		state_out		// state output for 7-segment display
);

reg [2:0] state;

assign state_out = state; 

localparam PC = 3'd0, Fetch = 3'd1, LDR = 3'd2, Arit = 3'd3, WB_Rd = 3'd4, Logica = 3'd5, WB_R0 = 3'd6;

// Transitions between states always block:

always@(posedge clk, negedge rst) 
	begin
		if(!rst)
			state <= Fetch;
		else 
			case (state)
				PC: 
					if(pc_ack) state <= Fetch; 
					else state <= PC;
				Fetch: 
					if(ri_ack)
						case(mnm_in)
							2'b00: state <= LDR;
							2'b01: state <= Logica;
							2'b10: state <= Arit;
							2'b11: state <= Arit;
							default: state <= Fetch;
						endcase
					else state <= Fetch;
				LDR:
					if(wr_ack) state <= PC; 
					else state <= LDR;
				Arit:
					if(ula_ack) state <= WB_Rd; 
					else state <= Arit;
				WB_Rd:
					if(wr_ack) state <= PC;
					else state <= WB_Rd;
				Logica:
					if(ula_ack) state <= WB_R0;
					else state <= Logica;
				WB_R0:
					if(wr_ack) state <= PC;
					else state <= WB_R0;
				default: state <= Fetch;
			endcase
	end
	
// Outputs combinational always block:

always@(*) 
	begin
		ena_pc = 0;
		ena_ri = 0;
		ena_wr = 0;
		sel_r0_rd = 0;
		sel_addr_data = 0;
		sel_ldr_ula = 0;
		ena_ula = 0;	
		case(state)
			PC: 	begin ena_pc = 1'b1; ena_ri = 1'b0; ena_wr = 1'b0; sel_r0_rd = 1'b0; sel_addr_data = 1'b0; sel_ldr_ula = 1'b0; ena_ula = 1'b0; end
			Fetch: 	begin ena_pc = 1'b0; ena_ri = 1'b1; ena_wr = 1'b0; sel_r0_rd = 1'b0; sel_addr_data = 1'b0; sel_ldr_ula = 1'b0; ena_ula = 1'b0; end
			LDR: 	begin ena_pc = 1'b0; ena_ri = 1'b0; ena_wr = 1'b1; sel_r0_rd = 1'b1; sel_addr_data = 1'b0; sel_ldr_ula = 1'b1; ena_ula = 1'b0; end
			Arit: 	begin ena_pc = 1'b0; ena_ri = 1'b0; ena_wr = 1'b0; sel_r0_rd = 1'b0; sel_addr_data = 1'b1; sel_ldr_ula = 1'b0; ena_ula = 1'b1; end
			WB_Rd:	begin ena_pc = 1'b0; ena_ri = 1'b0; ena_wr = 1'b1; sel_r0_rd = 1'b1; sel_addr_data = 1'b0; sel_ldr_ula = 1'b0; ena_ula = 1'b0; end
			Logica:	begin ena_pc = 1'b0; ena_ri = 1'b0; ena_wr = 1'b0; sel_r0_rd = 1'b0; sel_addr_data = 1'b1; sel_ldr_ula = 1'b0; ena_ula = 1'b1; end
			WB_R0:	begin ena_pc = 1'b0; ena_ri = 1'b0; ena_wr = 1'b1; sel_r0_rd = 1'b0; sel_addr_data = 1'b0; sel_ldr_ula = 1'b0; ena_ula = 1'b0; end
		endcase
	end
endmodule