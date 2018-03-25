module mem_mux(
	input [15:0] rf_out,
	input [15:0] pc_out,
	input mem_mux_sel,
	output [15:0] o_mem_addr
	);

assign o_mem_addr[15:1]= mem_mux_sel? pc_out[15:1] : rf_out[15:1];
assign o_mem_addr[0]=0;

endmodule // mem_mux