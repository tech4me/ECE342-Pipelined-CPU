module rf_mux(
	input [15:0]alu_out,
	input [15:0]i_mem_rddata,
	input rf_mux_sel,
	output logic [15:0]rf_mux_out
	);
always_comb begin
	case (rf_mux_sel)
		1'b0: rf_mux_out=alu_out;
		1'b1: rf_mux_out=i_mem_rddata;
		default: rf_mux_out=alu_out;
	endcase
end

endmodule // rf_mux