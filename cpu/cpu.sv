/*module cpu(
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
*/

module cpu
    (
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
//edge btw writeback and fetch
    //fetch stage
stage_fetch u_stage_fetch(
	.valid_in    (valid_in    ),
    .pc_out      (pc_out      ),
    .o_pc_addr   (o_pc_addr   ),
    .o_pc_rd     (o_pc_rd     ),
    .valid_out   (valid_out   ),
    .pc_fetch_en (pc_fetch_en )
);

pc u_pc_writeback(
    .clk           (clk           ),
    .rst           (rst           ),
    .pc_mux_out_in (pc_mux_out_in ),
    .inc           (inc           ),
    .enable        (enable        ),
    .pc_out        (pc_out        )
);

rf u_rf_rf_read_writeback(
    .clk       (clk       ),
    .rst       (rst       ),
    .addr      (addr      ),
    .data_in   (data_in   ),
    .rf_addr_A (rf_addr_A ),
    .rf_addr_B (rf_addr_B ),
    .only_high (only_high ),
    .write_en  (write_en  ),
    .rf_out_A  (rf_out_A  ),
    .rf_out_B  (rf_out_B  )
);

//edge btw fetch and rf_read
    //rf_read stage
stage_rf_read u_stage_rf_read(
	.valid_in  (valid_in  ),
    .mem_data  (mem_data  ),
    .valid_out (valid_out ),
    .ir_enable (ir_enable ),
    .ir        (ir        ),
    .rf_sel_A  (rf_sel_A  ),
    .rf_sel_B  (rf_sel_B  )
);

valid_bit u_valid_bit_fetch(
	.clk       (clk       ),
    .rst       (rst       ),
    .enable    (enable    ),
    .valid_in  (valid_in  ),
    .valid_out (valid_out )
);

    //memory

//edge btw rf_read and execute
    //execute
stage_execute u_stage_execute(
	.valid_in          (valid_in          ),
    .rf_out_A          (rf_out_A          ),
    .rf_out_B          (rf_out_B          ),
    .ir_in_execute     (ir_in_execute     ),
    .z                 (z                 ),
    .n                 (n                 ),
    .valid_out         (valid_out         ),
    .alu_out           (alu_out           ),
    .o_ldst_addr       (o_ldst_addr       ),
    .o_ldst_rd         (o_ldst_rd         ),
    .o_ldst_wr         (o_ldst_wr         ),
    .o_ldst_wrdata     (o_ldst_wrdata     ),
    .wire_z            (wire_z            ),
    .wire_n            (wire_n            ),
    .z_en              (z_en              ),
    .n_en              (n_en              ),
    .ir_out_execute    (ir_out_execute    ),
    .alu_result_en     (alu_result_en     ),
    .ir_out_execute_en (ir_out_execute_en )
);

valid_bit u_valid_bit_rf_read(
	.clk       (clk       ),
    .rst       (rst       ),
    .enable    (enable    ),
    .valid_in  (valid_in  ),
    .valid_out (valid_out )
);

ir u_ir_rf_read(
    .clk       (clk       ),
    .rst       (rst       ),
    .ir_enable (ir_enable ),
    .ir_in     (ir_in     ),
    .ir_out    (ir_out    )
);

    //rf

//edge btw execute and writeback
    //writeback stage
stage_writeback u_stage_writeback(
	.valid       (valid       ),
    .ir          (ir          ),
    .alu_reg     (alu_reg     ),
    .mem_data    (mem_data    ),
    .z           (z           ),
    .n           (n           ),
    .rf_write_en (rf_write_en ),
    .only_high   (only_high   ),
    .rf_addr     (rf_addr     ),
    .rf_data     (rf_data     ),
    .pc_enable   (pc_enable   ),
    .pc          (pc          )
);

ir u_ir_execute(
    .clk       (clk       ),
    .rst       (rst       ),
    .ir_enable (ir_enable ),
    .ir_in     (ir_in     ),
    .ir_out    (ir_out    )
);

alu_result_reg u_alu_result_reg(
	.clk     (clk     ),
    .rst     (rst     ),
    .enable  (enable  ),
    .reg_in  (reg_in  ),
    .reg_out (reg_out )
);


flag u_flag_execute(
    .clk  (clk  ),
    .rst  (rst  ),
    .i_z  (i_z  ),
    .i_n  (i_n  ),
    .z_en (z_en ),
    .n_en (n_en ),
    .o_z  (o_z  ),
    .o_n  (o_n  )
);

valid_bit u_valid_bit_execute(
	.clk       (clk       ),
    .rst       (rst       ),
    .enable    (enable    ),
    .valid_in  (valid_in  ),
    .valid_out (valid_out )
);

    //memory
    
endmodule
    
    