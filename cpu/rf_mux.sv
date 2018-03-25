module rf_mux(
	input [15:0]pc_out,
	input [15:0]alu_out,
	input [15:0]i_mem_rddata,
	input [1:0] rf_mux_sel,
	output logic [15:0]rf_mux_out
	);
always_comb begin
	case (rf_mux_sel)
		2'd0: rf_mux_out=pc_out;
		2'd1: rf_mux_out=alu_out;
		2'd2: rf_mux_out=i_mem_rddata;
		default: rf_mux_out=i_mem_rddata;
	endcase
end

endmodule // rf_mux