`include "op.svh"
module stage_rf_read (
    input valid_in,
    input [15:0] mem_data,
    input [15:0] rf_A,
    input [15:0] rf_B,
    input [15:0] i_alu_reg_from_writeback_stage_in_rf_read_stage,
    input [1:0] detect_reg_in_rf_read_stage,


    //for branch
    input set_invalid_sig_to_rf_read,
    input [15:0] pc_in_plus_2,
   /* input forwarding_z,
    input forwarding_n,
    input z,
    input n,
    input [15:0] i_ir_out_in_execute_stage,
    
    output [15:0] pc_to_be_jumped,
    output branch_sig,*/

    //for ld and st in rf read stage
    input  [1:0] detect_reg_in_rf_read_stage_ld_st,
    input  [15:0] i_alu_reg_from_writeback_stage_in_rf_read_stage_ld_st,
    output logic [15:0] o_ldst_addr,
	output logic o_ldst_rd,
	output logic o_ldst_wr,
    output [15:0] o_ldst_wrdata,


    output valid_out,
    output ir_enable,
    output [15:0] ir,
    output [2:0]rf_sel_A,
    output [2:0]rf_sel_B,
    output reg_A_en,
    output reg_B_en,
    output [15:0] reg_A,
    output [15:0] reg_B,

    output [15:0] rf_A_forward_out//for branching as output 
);

assign valid_out = set_invalid_sig_to_rf_read? 0 : valid_in;
assign ir_enable = valid_in;

assign ir = mem_data;

assign rf_sel_A = mem_data[7:5];
assign rf_sel_B = mem_data[10:8];

assign reg_A_en = valid_in;
assign reg_B_en = valid_in;

logic [1:0] alu_mux_a_sel;
logic [2:0] alu_mux_b_sel;

//logic [15:0]rf_A_forward_out;
logic [15:0]rf_B_forward_out;

/*pc_controller u_pc_controller(
	.mem_data                  (mem_data                  ),
    .forwarding_z              (forwarding_z              ),
    .forwarding_n              (forwarding_n              ),
    .z                         (z                         ),
    .n                         (n                         ),
    .i_ir_out_in_execute_stage (i_ir_out_in_execute_stage ),
    .forwarding_reg_A          (rf_A_forward_out          ),
    .pc_in_plus_2              (pc_in_plus_2              ),
    .pc_to_be_jumped           (pc_to_be_jumped           ),
    .branch_sig                (branch_sig                ) 
);*/


always_comb begin
    case(mem_data[3:0])
        OP_MV_X:  alu_mux_a_sel = 1;
        OP_MVHI:  alu_mux_a_sel = 3;
        OP_J_X: begin
                    if(mem_data[4])
                        alu_mux_a_sel = 2;
                    else
                        alu_mux_a_sel = 0;
                end
        OP_JN_X: begin
                    if(mem_data[4])
                        alu_mux_a_sel = 2;
                    else
                        alu_mux_a_sel = 0;
                 end
        OP_JZ_X: begin
                    if(mem_data[4])
                        alu_mux_a_sel = 2;
                    else
                        alu_mux_a_sel = 0;
                 end
        OP_LD: alu_mux_a_sel=1;
        OP_ST: alu_mux_a_sel=1;
        OP_CALL_X:begin
                    //if(mem_data[4])
                     //   alu_mux_a_sel = 2;
                    //else
                    //    alu_mux_a_sel = 0;
                    alu_mux_a_sel = 1'b1;
                  end  
        default:  begin 
            alu_mux_a_sel = 0;
            end
    endcase
end

always_comb begin
    case(mem_data[3:0])
        OP_MV_X:  alu_mux_b_sel=mem_data[4] ? 0 : 1;
        OP_ADD_X: alu_mux_b_sel=mem_data[4] ? 0 : 1;
        OP_SUB_X: alu_mux_b_sel=mem_data[4] ? 0 : 1;
        OP_CMP_X: alu_mux_b_sel=mem_data[4] ? 0 : 1;
        OP_MVHI:  alu_mux_b_sel=3;
        OP_LD: alu_mux_b_sel=1;
        OP_ST: alu_mux_b_sel=1;
        OP_CALL_X:alu_mux_b_sel=2;
        default: begin 
                    alu_mux_b_sel = 0;
                 end
    endcase
end


assign rf_A_forward_out = detect_reg_in_rf_read_stage[0]?  i_alu_reg_from_writeback_stage_in_rf_read_stage: rf_A;
assign rf_B_forward_out = detect_reg_in_rf_read_stage[1]?  i_alu_reg_from_writeback_stage_in_rf_read_stage: rf_B;
alu_mux u_alu_mux(
	.rf_out_A      (rf_A_forward_out),
	.ir_out_imm8   (mem_data[15:8]  ),
    .ir_out_imm11  (mem_data[15:5]  ),
	.rf_out_B      (rf_B_forward_out),
	.pc_out        (pc_in_plus_2       ),
	.alu_mux_a_sel (alu_mux_a_sel ),
	.alu_mux_b_sel (alu_mux_b_sel ),
	.alu_mux_A_out (reg_A ),
	.alu_mux_B_out (reg_B )
);


assign o_ldst_wrdata = detect_reg_in_rf_read_stage_ld_st[0]? i_alu_reg_from_writeback_stage_in_rf_read_stage_ld_st : rf_A_forward_out;

always_comb begin
    case(mem_data[3:0])
        OP_LD: begin 
                o_ldst_rd = valid_out;
			    o_ldst_wr=0;
                o_ldst_addr [15:1] = detect_reg_in_rf_read_stage_ld_st[1]? i_alu_reg_from_writeback_stage_in_rf_read_stage_ld_st[15:1] : rf_B_forward_out[15:1];
                o_ldst_addr[0] = 0;
               end
        OP_ST: begin
                o_ldst_wr = valid_out;
			    o_ldst_rd=0;
                o_ldst_addr [15:1] = detect_reg_in_rf_read_stage_ld_st[1]? i_alu_reg_from_writeback_stage_in_rf_read_stage_ld_st[15:1] : rf_B_forward_out[15:1];
                o_ldst_addr[0] = 0;
               end
        default: begin
                o_ldst_rd=0;
                o_ldst_wr=0;
                o_ldst_addr = 0;
            end
    endcase
end

endmodule
