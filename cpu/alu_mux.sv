module alu_mux(
	input [15:0]rf_out_A,
	input [7:0] ir_out_imm8,
	input [15:0] rf_out_B,
	input [15:0] pc_out,
	input alu_mux_a_sel,
	input [2:0] alu_mux_b_sel,
	output [15:0] alu_mux_A_out,
	output logic [15:0] alu_mux_B_out
	);

assign alu_mux_A_out=alu_mux_a_sel? 16'd0 : rf_out_A;

always_comb begin
	case(alu_mux_b_sel)
		3'd0: alu_mux_B_out= {{8{ir_out_imm8[7]}},ir_out_imm8};
		3'd1: alu_mux_B_out= rf_out_B;
		3'd2: alu_mux_B_out= pc_out; 
		3'd3: alu_mux_B_out= {ir_out_imm8, 8'd0};
		default: alu_mux_B_out= 16'd0;
	endcase // alu_out_b_sel
end

endmodule // alu_mux