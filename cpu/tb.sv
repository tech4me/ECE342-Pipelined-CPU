module tbtest();

logic clk;
initial clk = 1'b0; // Clock starts at 0
always #10 clk = ~clk; // Wait 10ns, flip the clock, repeat forever
logic rst;

logic [15:0] o_mem_addr;
logic [15:0] i_mem_rddata;
logic [15:0] o_mem_wrdata;
logic pc_inc;
logic [1:0] pc_mux_sel;
logic ir_enable;
logic alu_sub;
logic alu_mux_a_sel;
logic [2:0] alu_mux_b_sel;
logic [2:0] rf_w_addr;
logic rf_only_high;
logic [1:0] rf_mux_sel;
logic mem_mux_sel;
logic z_en;
logic n_en;
logic  [15:0] ir_out;
logic  z;
logic  n;
logic rf_write_en;
datapath u_datapath(
    .clk           (clk           ),
    .rst           (rst           ),
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

initial begin
    rst = 1'b1; // Start with reset on
    @(posedge clk);
    rst = 1'b0; // Leave it on for a clock cycle and then turn it off
	pc_inc=0;
	pc_mux_sel=2;
	ir_enable=0;
	alu_sub=0;
	alu_mux_a_sel=0;
	alu_mux_b_sel=0;
	rf_w_addr=0;
	rf_only_high=0;
	rf_mux_sel=1;
	mem_mux_sel=1;
	z_en=0;
	n_en=0;
	rf_write_en=0;
	i_mem_rddata=16'b1000110001010001;

	@(posedge clk);
	@(posedge clk);
	ir_enable=1;
	@(posedge clk);
	ir_enable=0;
	pc_inc=1;
	alu_mux_a_sel=0;
	alu_mux_b_sel=0;
	rf_w_addr=2;
	z_en=1;
	n_en=1;
	rf_write_en=1;
	@(posedge clk);
	#20;
	$stop();
end
    
endmodule

/*
vlog *.sv
vsim -novopt tb

run -all

vlog *.sv
restart -f
run -all

*/