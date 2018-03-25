module datapath(
	input clk,
	input rst,
	output [15:0] o_pc_addr, //new
	input [15:0] i_pc_rddata, //new

	output [15:0] o_mem_wrdata,

	input pc_inc,
	input [1:0] pc_mux_sel,
	input ir_enable,
	input alu_sub,
	input alu_mux_a_sel,
	input [2:0] alu_mux_b_sel,
	input [2:0] rf_w_addr,
	input rf_write_en,
	input rf_only_high,
	input [1:0] rf_mux_sel,
	input mem_mux_sel,
	input z_en,
	input n_en,
	output [15:0] ir_out_rf_read, //new
	output [15:0] ir_out_execute, //new
	output z,
	output n
	);

logic [15:0] pc_mux_out;
logic [15:0] pc_out;
logic [15:0] rf_a_out;
logic [15:0] rf_b_out;
logic [15:0] alu_mux_a_out;
logic [15:0] alu_mux_b_out;
logic wire_z;
logic wire_n;
logic [15:0] rf_mux_out;
logic [15:0] alu_out;
assign o_mem_wrdata = alu_mux_a_out;
pc u_pc(
	.clk           (clk         ),
	.rst           (rst         ),
	.pc_mux_out_in (pc_mux_out  ),
	.inc           (pc_inc      ),
	.pc_out        (pc_out      )
);

pc_mux u_pc_mux(
	.ir_out_in  (ir_out[15:5] ),
	.rf_out_in  (rf_a_out     ),
	.pc_out_in  (pc_out       ),
	.pc_mux_sel (pc_mux_sel   ),
	.pc_mux_out (pc_mux_out   )
);

ir u_ir_rf_read(//new
	.clk           (clk           ),
	.rst           (rst           ),
	.ir_enable     (ir_enable     ),
	.ir_in         (i_pc_rddata   ),
	.ir_out        (ir_out_rf_read)
);
ir u_ir_execute(//new
	.clk           (clk           ),
	.rst           (rst           ),
	.ir_enable     (ir_enable     ),
	.ir_in         (ir_out_rf_read),
	.ir_out        (ir_out_execute)
);

mem_mux u_mem_mux(
	.rf_out      (rf_b_out    ),
	.pc_out      (pc_out      ),
	.mem_mux_sel (mem_mux_sel ),
	.o_mem_addr  (o_mem_addr  )
);

alu u_alu(
	.in_a    (alu_mux_a_out ),
	.in_b    (alu_mux_b_out ),
	.sub     (alu_sub       ),
	.alu_out (alu_out       ),
	.z       (wire_z        ),
	.n       (wire_n        )
);

alu_mux u_alu_mux(
	.rf_out_A      (rf_a_out      ),
	.ir_out_imm8   (ir_out[15:8]  ),
	.rf_out_B      (rf_b_out      ),
	.pc_out        (pc_out        ),
	.alu_mux_a_sel (alu_mux_a_sel ),
	.alu_mux_b_sel (alu_mux_b_sel ),
	.alu_mux_A_out (alu_mux_a_out ),
	.alu_mux_B_out (alu_mux_b_out )
);

flag u_flag(
	.clk (clk    ),
	.rst (rst    ),
	.i_z (wire_z ),
	.i_n (wire_n ),
	.z_en(z_en   ),
	.n_en(n_en   ),
	.o_z (z      ),
	.o_n (n      )
);

rf u_rf(
	.clk       (clk          ),
	.rst       (rst          ),
	.addr      (rf_w_addr    ),
	.data_in   (rf_mux_out   ),
	.rf_addr_A (ir_out[7:5]  ),
	.rf_addr_B (ir_out[10:8] ),
	.only_high (rf_only_high ),
	.write_en  (rf_write_en  ),
	.rf_out_A  (rf_a_out     ),
	.rf_out_B  (rf_b_out     )
);

rf_mux u_rf_mux(
	.pc_out       (pc_out       ),
	.alu_out      (alu_out      ),
	.i_mem_rddata (i_mem_rddata ),
	.rf_mux_sel   (rf_mux_sel   ),
	.rf_mux_out   (rf_mux_out   )
);

endmodule // datapath