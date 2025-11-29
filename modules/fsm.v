module fsm(
	input wire [1:0] 	mnm_in,		// campo mnemonico da instrucao
	input wire 			clk,			// clock
	input wire 			rst,			// reset global
	input wire 			ula_ack,		// handshaking de fim da ula
	input wire			wr_ack,		// handshaking de fim do banco
	input wire			pc_ack,		// handshaking de fim do PC
	input wire 			ri_ack,		// handshaking de fim do RI
	output reg			ena_pc,		// habilita contador de programa
	output reg 			ena_ri,		// habilita registro de instrução
	output reg 			ena_wr,		//	habilita escrita no banco
	output reg 			sel_r0_rd,	//	seleção de endereço de escrita no banco
	output reg 			sel_addr_data,	// seleção de dados ou endereços
	output reg			sel_ldr_ula,	// seleção da fonte de dados para o banco
	output reg			ena_ula,		// habilita aula
	output [2:0] 		state_out		// estado para verificacao no display de 7 segmentos
);

reg [2:0] state;

assign state_out = state; 

localparam PC = 3'd0, Fetch = 3'd1, LDR = 3'd2, Arit = 3'd3, WB_Rd = 3'd4, Logica = 3'd5, WB_R0 = 3'd6;

always@(posedge clk, negedge rst) // bloco always de transicao dos estados
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
	
always@(*) // bloco always das atribuicoes das saidas
	begin
		ena_pc = 0;
		ena_ri = 0;
		ena_wr = 0;
		sel_r0_rd = 0;
		sel_addr_data = 0;
		sel_ldr_ula = 0;
		ena_ula = 0;	
		case(state)
			PC: 		begin ena_pc = 1'b1; ena_ri = 1'b0; ena_wr = 1'b0; sel_r0_rd = 1'b0; sel_addr_data = 1'b0; sel_ldr_ula = 1'b0; ena_ula = 1'b0; end
			Fetch: 	begin ena_pc = 1'b0; ena_ri = 1'b1; ena_wr = 1'b0; sel_r0_rd = 1'b0; sel_addr_data = 1'b0; sel_ldr_ula = 1'b0; ena_ula = 1'b0; end
			LDR: 		begin ena_pc = 1'b0; ena_ri = 1'b0; ena_wr = 1'b1; sel_r0_rd = 1'b1; sel_addr_data = 1'b0; sel_ldr_ula = 1'b1; ena_ula = 1'b0; end
			Arit: 	begin ena_pc = 1'b0; ena_ri = 1'b0; ena_wr = 1'b0; sel_r0_rd = 1'b0; sel_addr_data = 1'b1; sel_ldr_ula = 1'b0; ena_ula = 1'b1; end
			WB_Rd:	begin ena_pc = 1'b0; ena_ri = 1'b0; ena_wr = 1'b1; sel_r0_rd = 1'b1; sel_addr_data = 1'b0; sel_ldr_ula = 1'b0; ena_ula = 1'b0; end
			Logica:	begin ena_pc = 1'b0; ena_ri = 1'b0; ena_wr = 1'b0; sel_r0_rd = 1'b0; sel_addr_data = 1'b1; sel_ldr_ula = 1'b0; ena_ula = 1'b1; end
			WB_R0:	begin ena_pc = 1'b0; ena_ri = 1'b0; ena_wr = 1'b1; sel_r0_rd = 1'b0; sel_addr_data = 1'b0; sel_ldr_ula = 1'b0; ena_ula = 1'b0; end
		endcase
	end
endmodule