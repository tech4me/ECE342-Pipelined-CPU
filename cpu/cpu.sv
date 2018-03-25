module cpu(
    input clk,
    input reset,
    output [15:0]o_mem_addr,
    output o_mem_rd,
    input [15:0]i_mem_rddata,
    output o_mem_wr,
    output [15:0]o_mem_wrdata



//new
	input clk,
	input reset,
	
	output [15:0] o_pc_addr,
	output o_pc_rd,
	input [15:0] i_pc_rddata,
	
	output [15:0] o_ldst_addr,
	output o_ldst_rd,
	output o_ldst_wr,
	input [15:0] i_ldst_rddata,
	output [15:0] o_ldst_wrdata,
	
	output [7:0][15:0] o_tb_regs
);

	logic pc_inc;
	logic [1:0] pc_mux_sel;
	logic ir_enable;
	logic alu_sub;
	logic alu_mux_a_sel;
	logic [2:0] alu_mux_b_sel;
	logic [2:0] rf_w_addr;
	logic rf_write_en;
	logic rf_only_high;
	logic [1:0] rf_mux_sel;
	logic mem_mux_sel;
	logic z_en;
	logic n_en;
	logic [15:0] ir_out;
	logic z;
	logic n;
    
datapath u_datapath(
	.clk           (clk           ),
    .rst           (reset         ),
    .o_mem_addr    (o_mem_addr    ),
    .i_mem_rddata  (i_mem_rddata  ),
    .o_mem_wrdata  (o_mem_wrdata  ),
    .pc_inc        (pc_inc        ),
    .pc_mux_sel    (pc_mux_sel    ),
    .ir_enable     (ir_enable     ),
    .alu_sub       (alu_sub       ),
    .alu_mux_a_sel (alu_mux_a_sel ),
    .alu_mux_b_sel (alu_mux_b_sel ),
    .rf_w_addr     (rf_w_addr     ),
    .rf_write_en   (rf_write_en   ),
    .rf_only_high  (rf_only_high  ),
    .rf_mux_sel    (rf_mux_sel    ),
    .mem_mux_sel   (mem_mux_sel   ),
    .z_en          (z_en          ),
    .n_en          (n_en          ),
    .ir_out        (ir_out        ),
    .z             (z             ),
    .n             (n             )
);
control u_control(
	.clk           (clk           ),
    .rst           (reset         ),
    .ir_out        (ir_out        ),
    .i_mem_rddata  (i_mem_rddata  ),
    .z             (z             ),
    .n             (n             ),
    .pc_inc        (pc_inc        ),
    .pc_mux_sel    (pc_mux_sel    ),
    .ir_enable     (ir_enable     ),
    .alu_sub       (alu_sub       ),
    .alu_mux_a_sel (alu_mux_a_sel ),
    .alu_mux_b_sel (alu_mux_b_sel ),
    .rf_w_addr     (rf_w_addr     ),
    .rf_write_en   (rf_write_en   ),
    .rf_only_high  (rf_only_high  ),
    .rf_mux_sel    (rf_mux_sel    ),
    .mem_mux_sel   (mem_mux_sel   ),
    .z_en          (z_en          ),
    .n_en          (n_en          ),
    .o_mem_rd      (o_mem_rd      ),
    .o_mem_wr      (o_mem_wr      )
);

endmodule