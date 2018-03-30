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
logic [15:0] o_pc_mux_out_in_writeback_stage;
logic o_pc_enable_in_writeback_stage;

logic [2:0] o_rf_addr_in_writeback_stage;
logic [15:0] o_rf_data_in_in_writeback_stage;

logic o_only_high_in_writeback_stage;
logic o_write_en_in_writeback_stage;

logic o_pc_inc_in_fetch_stage;

logic [15:0] i_pc_out_in_fetch_stage;

logic o_valid_out_in_fetch_stage;

logic [15:0] i_rf_out_A_to_forward_mux;
logic [15:0] i_rf_out_B_to_forward_mux;

logic [15:0] i_rf_out_a_in_execute_stage;
logic [15:0] i_rf_out_b_in_execute_stage;

logic o_pc_fetch_enable_in_fetch_stage;

//forwarding comb logic
logic [15:0] i_ir_out_in_writeback_stage;
logic [15:0] i_ir_out_in_execute_stage;
logic [15:0] i_alu_reg_in_writeback_stage;

logic [1:0]detect_reg_in_rf_read_stage;
logic [1:0]detect_reg_in_execute_stage;
logic [15:0] i_alu_reg_from_writeback_stage_in_execute_stage;
logic [15:0] i_alu_reg_from_writeback_stage_in_rf_read_stage;
seq_detect u_seq_detect(
	.o_mem_data_in_rf_read_stage                     (i_pc_rddata                     ),
    .i_ir_out_in_execute_stage                       (i_ir_out_in_execute_stage                       ),
    .i_ir_out_in_writeback_stage                     (i_ir_out_in_writeback_stage                     ),
    .i_alu_reg_in_writeback_stage                    (i_alu_reg_in_writeback_stage                    ),
    .detect_reg_in_rf_read_stage                     (detect_reg_in_rf_read_stage                     ),
    .detect_reg_in_execute_stage                     (detect_reg_in_execute_stage                     ),
    .i_alu_reg_from_writeback_stage_in_execute_stage (i_alu_reg_from_writeback_stage_in_execute_stage ),
    .i_alu_reg_from_writeback_stage_in_rf_read_stage (i_alu_reg_from_writeback_stage_in_rf_read_stage )
);


    //fetch stage
stage_fetch u_stage_fetch(
	.valid_in    (1'b1    ),
    .pc_out      (i_pc_out_in_fetch_stage),
    .o_pc_addr   (o_pc_addr   ),
    .o_pc_rd     (o_pc_rd     ),
    .valid_out   (o_valid_out_in_fetch_stage   ),
    .pc_fetch_inc (o_pc_inc_in_fetch_stage),
    .pc_fetch_en (o_pc_fetch_enable_in_fetch_stage)
);

pc u_pc_writeback(
    .clk           (clk           ),
    .rst           (reset           ),
    .pc_mux_out_in (o_pc_mux_out_in_writeback_stage ),
    .inc           (o_pc_inc_in_fetch_stage           ),
    .enable        (o_pc_enable_in_writeback_stage | o_pc_fetch_enable_in_fetch_stage       ),
    .pc_out        (i_pc_out_in_fetch_stage        )
);

logic [2:0] o_rf_sel_A_in_rf_read_stage;
logic [2:0] o_rf_sel_B_in_rf_read_stage;

assign i_rf_out_A_to_forward_mux = detect_reg_in_rf_read_stage[0]? i_alu_reg_from_writeback_stage_in_rf_read_stage : i_rf_out_a_in_execute_stage;
assign i_rf_out_B_to_forward_mux = detect_reg_in_rf_read_stage[1]? i_alu_reg_from_writeback_stage_in_rf_read_stage: i_rf_out_b_in_execute_stage;

rf u_rf_rf_read_writeback(
    .clk       (clk       ),
    .rst       (reset       ),
    .addr      (o_rf_addr_in_writeback_stage      ),
    .data_in   (o_rf_data_in_in_writeback_stage   ),
    .rf_addr_A (o_rf_sel_A_in_rf_read_stage ),
    .rf_addr_B (o_rf_sel_B_in_rf_read_stage ),
    .only_high (o_only_high_in_writeback_stage ),
    .write_en  (o_write_en_in_writeback_stage  ),
    .rf_out_A  (i_rf_out_a_in_execute_stage  ),
    .rf_out_B  (i_rf_out_b_in_execute_stage  ),
    .rf        (o_tb_regs )
);


//edge btw fetch and rf_read
    //rf_read stage
logic i_valid_out_in_rf_read_stage;
logic o_valid_out_in_rf_read_stage;
logic o_ir_enable_in_rf_read_stage;
logic [15:0] o_ir_in_rf_read_stage;

logic o_reg_A_en_in_rf_read_stage;
logic o_reg_B_en_in_rf_read_stage;

stage_rf_read u_stage_rf_read(
	.valid_in  (i_valid_out_in_rf_read_stage  ),
    .mem_data  (i_pc_rddata  ),
    .valid_out (o_valid_out_in_rf_read_stage ),
    .ir_enable (o_ir_enable_in_rf_read_stage ),
    .ir        (o_ir_in_rf_read_stage        ),
    .rf_sel_A  (o_rf_sel_A_in_rf_read_stage  ),
    .rf_sel_B  (o_rf_sel_B_in_rf_read_stage  ),
    .reg_A_en  (o_reg_A_en_in_rf_read_stage),
    .reg_B_en  (o_reg_B_en_in_rf_read_stage)
);

valid_bit u_valid_bit_fetch(
	.clk       (clk       ),
    .rst       (reset       ),
    .enable    (1'b1    ),//part3
    .valid_in  (o_valid_out_in_fetch_stage  ),
    .valid_out (i_valid_out_in_rf_read_stage )
);

    //memory

//edge btw rf_read and execute
logic i_valid_out_in_execute_stage;
logic o_valid_out_in_execute_stage;
logic [15:0] o_alu_out_in_execute_stage;
logic o_wire_z_in_execute_stage;
logic o_wire_n_in_execute_stage;
logic o_z_en_in_execute_stage;
logic o_n_en_in_execute_stage;
logic [15:0] o_ir_out_in_execute_stage;
logic o_alu_result_en_in_execute_stage;
logic o_ir_enable_in_execute_stage;
logic [15:0] i_rf_reg_out_A_in_execute_stage;
logic [15:0] i_rf_reg_out_B_in_execute_stage;
    //execute
stage_execute u_stage_execute(
	.valid_in          (i_valid_out_in_execute_stage          ),
    .rf_out_A          (i_rf_reg_out_A_in_execute_stage          ),
    .rf_out_B          (i_rf_reg_out_B_in_execute_stage          ),
    .ir_in_execute     (i_ir_out_in_execute_stage     ),
    .rf_forward_data(i_alu_reg_from_writeback_stage_in_execute_stage),
    .rf_forward_sel(detect_reg_in_execute_stage),
    .z                 (1'b1                 ),//part3
    .n                 (1'b1              ),//part3
    .valid_out         (o_valid_out_in_execute_stage         ),
    .alu_out           (o_alu_out_in_execute_stage           ),
    .o_ldst_addr       (o_ldst_addr       ),
    .o_ldst_rd         (o_ldst_rd         ),
    .o_ldst_wr         (o_ldst_wr         ),
    .o_ldst_wrdata     (o_ldst_wrdata     ),
    .wire_z            (o_wire_z_in_execute_stage            ),
    .wire_n            (o_wire_n_in_execute_stage            ),
    .z_en              (o_z_en_in_execute_stage              ),
    .n_en              (o_n_en_in_execute_stage              ),
    .ir_out_execute    (o_ir_out_in_execute_stage    ),
    .alu_result_en     (o_alu_result_en_in_execute_stage     ),
    .ir_out_execute_en (o_ir_enable_in_execute_stage )
);

valid_bit u_valid_bit_rf_read(
	.clk       (clk       ),
    .rst       (reset       ),
    .enable    (1'b1    ),
    .valid_in  (o_valid_out_in_rf_read_stage  ),
    .valid_out (i_valid_out_in_execute_stage )
);

ir u_ir_rf_read(
    .clk       (clk       ),
    .rst       (reset       ),
    .ir_enable (o_ir_enable_in_rf_read_stage ),
    .ir_in     (o_ir_in_rf_read_stage     ),
    .ir_out    (i_ir_out_in_execute_stage    )
);

_16bit_reg u_rf_A(
	.clk     (clk     ),
    .rst     (reset     ),
    .enable  (o_reg_A_en_in_rf_read_stage  ),
    .reg_in  (i_rf_out_A_to_forward_mux  ),
    .reg_out (i_rf_reg_out_A_in_execute_stage )
);

_16bit_reg u_rf_B(
	.clk     (clk     ),
    .rst     (reset     ),
    .enable  (o_reg_B_en_in_rf_read_stage  ),
    .reg_in  (i_rf_out_B_to_forward_mux  ),
    .reg_out (i_rf_reg_out_B_in_execute_stage )
);


//edge btw execute and writeback
logic i_valid_out_in_writeback_stage;
logic i_z_in_writeback_stage;
logic i_n_in_writeback_stage;


    //writeback stage
stage_writeback u_stage_writeback(
	.valid       (i_valid_out_in_writeback_stage       ),
    .ir          (  i_ir_out_in_writeback_stage       ),
    .alu_reg     (i_alu_reg_in_writeback_stage     ),
    .mem_data    (i_ldst_rddata    ),
    .z           (i_z_in_writeback_stage           ),
    .n           (i_n_in_writeback_stage         ),
    .rf_write_en (o_write_en_in_writeback_stage ),
    .only_high   (o_only_high_in_writeback_stage   ),
    .rf_addr     (o_rf_addr_in_writeback_stage     ),
    .rf_data     ( o_rf_data_in_in_writeback_stage    ),
    .pc_enable   (o_pc_enable_in_writeback_stage   ),
    .pc          (o_pc_mux_out_in_writeback_stage          )
);

ir u_ir_execute(
    .clk       (clk       ),
    .rst       (reset       ),
    .ir_enable (o_ir_enable_in_execute_stage ),
    .ir_in     (o_ir_out_in_execute_stage     ),
    .ir_out    ( i_ir_out_in_writeback_stage   )
);

_16bit_reg u_alu_result_reg(
	.clk     (clk     ),
    .rst     (reset     ),
    .enable  (o_alu_result_en_in_execute_stage  ),
    .reg_in  (o_alu_out_in_execute_stage  ),
    .reg_out (i_alu_reg_in_writeback_stage )
);


flag u_flag_execute(
    .clk  (clk  ),
    .rst  (reset  ),
    .i_z  (o_wire_z_in_execute_stage  ),
    .i_n  (o_wire_n_in_execute_stage  ),
    .z_en (o_z_en_in_execute_stage ),
    .n_en (o_n_en_in_execute_stage ),
    .o_z  (i_z_in_writeback_stage  ),
    .o_n  (i_n_in_writeback_stage  )
);

valid_bit u_valid_bit_execute(
	.clk       (clk       ),
    .rst       (reset       ),
    .enable    (1'b1    ),
    .valid_in  (o_valid_out_in_execute_stage  ),
    .valid_out (i_valid_out_in_writeback_stage )
);

    //memory
    
endmodule
    
    
