module flag (
	input clk,
	input rst,
	input i_z,
	input i_n,
	input z_en,
	input n_en,
	output logic o_z,
	output logic o_n
	);
always_ff @(posedge clk) begin
	if(rst) begin
		o_z <= 0;
		o_n <= 0;
	end else begin
		if(z_en)
		o_z <= i_z;
		if(n_en)
		o_n <= i_n;
	end
end

endmodule // flag