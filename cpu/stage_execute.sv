module stage_execute(
    input valid_in,
	input [15:0]rf_out_A,
	input [15:0]rf_out_B,
    input [15:0]ir_in_execute,

    input z,//part3
    input n,//part3

    output valid_out,
    output [15:0] alu_out,

	output logic [15:0] o_ldst_addr,
	output logic o_ldst_rd,
	output logic o_ldst_wr,
	output [15:0] o_ldst_wrdata,

    output wire_z,
    output wire_n,
	output logic z_en,
	output logic n_en,    

    output [15:0]ir_out_execute,

    output alu_result_en,
    output ir_out_execute_en
);

`include "op.vh"
/*
case(i_mem_rddata[3:0])
    OP_MV_X:  nextstate = S_MV_X;
    OP_ADD_X: nextstate = S_ADD_X;
    OP_SUB_X: nextstate = S_SUB_X;
    OP_CMP_X: nextstate = S_CMP_X;
    OP_LD:    nextstate = S_LD_0;
    OP_ST:    nextstate = S_ST_0;
    OP_MVHI:  nextstate = S_MVHI;
    OP_J_X:   nextstate = S_J_X;
    OP_JN_X:  nextstate = S_JN_X;
    OP_JZ_X:  nextstate = S_JZ_X;
    OP_CALL_X:nextstate = S_CALL_X; 
    //default:
endcase
*/
logic [1:0] alu_mux_a_sel;
logic [2:0] alu_mux_b_sel;
logic [15:0] alu_mux_A_out;
logic [15:0] alu_mux_B_out;
logic alu_sub;
assign alu_result_en = valid_in;
assign ir_out_execute_en = valid_in;
assign ir_out_execute = ir_in_execute;
assign valid_out = valid_in;
assign alu_sub = ( (ir_in_execute[3:0] == OP_SUB_X) || (ir_in_execute[3:0]==OP_CMP_X) )? 1:0;

always_comb begin
    case(ir_in_execute[3:0])
        OP_ADD_X: begin 
                    z_en=1;
                    n_en=1;
                  end
        OP_SUB_X: begin 
                    z_en=1;
                    n_en=1;
                  end
        OP_CMP_X: begin 
                    z_en=1;
                    n_en=1;
                  end
        default:  begin 
                    z_en=0;
                    n_en=0;
                  end
    endcase
end

always_comb begin
    case(ir_in_execute[3:0])
        OP_MV_X:  alu_mux_a_sel = 1;
        OP_MVHI:  alu_mux_a_sel = 1;
        OP_CALL_X:  alu_mux_a_sel = 1;
        OP_J_X: begin
                    if(ir_in_execute[4])
                        alu_mux_a_sel = 2;
                    else
                        alu_mux_a_sel = 0;
                end
        OP_JN_X: begin
                    if(ir_in_execute[4])
                        alu_mux_a_sel = 2;
                    else
                        alu_mux_a_sel = 0;
                 end
        OP_JZ_X: begin
                    if(ir_in_execute[4])
                        alu_mux_a_sel = 2;
                    else
                        alu_mux_a_sel = 0;
                 end
        OP_CALL_X:begin
                    if(ir_in_execute[4])
                        alu_mux_a_sel = 2;
                    else
                        alu_mux_a_sel = 0;
                  end  
        default:  begin 
            alu_mux_a_sel = 0;
            end
    endcase
end

always_comb begin
    case(ir_in_execute[3:0])
        OP_MV_X:  alu_mux_b_sel=ir_in_execute[4] ? 0 : 1;
        OP_ADD_X: alu_mux_b_sel=ir_in_execute[4] ? 0 : 1;
        OP_SUB_X: alu_mux_b_sel=ir_in_execute[4] ? 0 : 1;
        OP_CMP_X: alu_mux_b_sel=ir_in_execute[4] ? 0 : 1;
        OP_MVHI:  alu_mux_b_sel=3;
        OP_CALL_X:alu_mux_b_sel=2;
        default: begin 
                    alu_mux_b_sel = 0;
                 end
    endcase
end

alu_mux u_alu_mux(
	.rf_out_A      (rf_out_A      ),
	.ir_out_imm8   (ir_in_execute[15:8]  ),
    .ir_out_imm11  (ir_in_execute[15:5]  ),
	.rf_out_B      (rf_out_B      ),
	.pc_out        (16'd127       ),//not implemented
	.alu_mux_a_sel (alu_mux_a_sel ),
	.alu_mux_b_sel (alu_mux_b_sel ),
	.alu_mux_A_out (alu_mux_A_out ),
	.alu_mux_B_out (alu_mux_B_out )
);

alu u_alu(
	.in_a    (alu_mux_A_out ),
	.in_b    (alu_mux_B_out ),
	.sub     (alu_sub       ),
	.alu_out (alu_out       ),
	.z       (wire_z        ),
	.n       (wire_n        )
);

assign o_ldst_wrdata = rf_out_A;

always_comb begin
    case(ir_in_execute[3:0])
        OP_LD: begin 
                o_ldst_rd = valid_in;
                o_ldst_addr [15:1] = rf_out_B [15:1];
                o_ldst_addr[0] = 0;
               end
        OP_ST: begin
                o_ldst_wr = valid_in;
                o_ldst_addr [15:1] = rf_out_B [15:1];
                o_ldst_addr[0] = 0;
               end
        default: begin
                    o_ldst_rd=0;
                    o_ldst_wr=0;
            end
    endcase
end



endmodule
