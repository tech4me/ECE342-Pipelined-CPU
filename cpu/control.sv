module control(
	input clk,
	input rst,
	input [15:0] ir_out,
	input [15:0] i_mem_rddata,
	input z,
	input n,
	output logic pc_inc,
	output logic [1:0] pc_mux_sel,
	output logic ir_enable,
	output logic alu_sub,
	output logic alu_mux_a_sel,
	output logic [2:0] alu_mux_b_sel,
	output logic [2:0] rf_w_addr,
	output logic rf_write_en,
	output logic rf_only_high,
	output logic [1:0] rf_mux_sel,
	output logic mem_mux_sel,
	output logic z_en,
	output logic n_en,
	output logic o_mem_rd,
	output logic o_mem_wr
	);

localparam
OP_MV_X  = 4'b0000,
OP_ADD_X = 4'b0001,
OP_SUB_X = 4'b0010,
OP_CMP_X = 4'b0011,
OP_LD    = 4'b0100,
OP_ST    = 4'b0101,
OP_MVHI  = 4'b0110,
OP_J_X   = 4'b1000,
OP_JZ_X  = 4'b1001,
OP_JN_X  = 4'b1010,
OP_CALL_X= 4'b1100;

enum int unsigned
{
S_FETCH_0,
S_FETCH_1,
S_MV_X,
S_ADD_X,
S_SUB_X,
S_CMP_X,
S_LD_0, 
S_LD_1,
S_ST_0,
S_ST_1,
S_MVHI,
S_J_X,
S_JN_X,
S_JZ_X,
S_CALL_X
} state, nextstate;


always_ff @(posedge clk) begin
	if(rst) begin
		state<=S_FETCH_0;
	end else begin
		 state<=nextstate;
	end
end

always_comb begin
	nextstate=S_FETCH_0;
	pc_inc=0;
	pc_mux_sel=2;
	ir_enable=0;
	alu_sub=0;
	alu_mux_a_sel=0;
	alu_mux_b_sel=0;
	rf_w_addr=0;
	rf_write_en=0;
	rf_only_high=0;
	rf_mux_sel=1;
	mem_mux_sel=1;
	z_en=0;
	n_en=0;
	o_mem_rd=0;
	o_mem_wr=0;
	case(state)
		S_FETCH_0: begin
			nextstate=S_FETCH_1;
			o_mem_rd=1;
		end
		S_FETCH_1: begin
			//nextstate=S_FETCH_2;
			pc_inc=1;
			ir_enable=1;
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
		end
		S_MV_X: begin
			alu_mux_a_sel=1;
			alu_mux_b_sel=ir_out[4] ? 0 : 1;
			rf_w_addr=ir_out[7:5];
			rf_write_en=1;
		end
		S_ADD_X: begin
			alu_mux_b_sel=ir_out[4] ? 0 : 1;
			z_en=1;
			n_en=1;
			rf_w_addr=ir_out[7:5];
			rf_write_en=1;
		end
		S_SUB_X: begin
			alu_mux_b_sel=ir_out[4] ? 0 : 1;
			alu_sub=1;
			z_en=1;
			n_en=1;
			rf_w_addr=ir_out[7:5];
			rf_write_en=1;		
		end
		S_CMP_X: begin
			alu_mux_b_sel=ir_out[4] ? 0 : 1;
			alu_sub=1;
			z_en=1;
			n_en=1;
		end
		S_LD_0: begin
			nextstate = S_LD_1;
			o_mem_rd=1;
			mem_mux_sel=0;
		end
		S_LD_1: begin
			rf_w_addr=ir_out[7:5];	
			rf_write_en=1;
			rf_mux_sel=2;
		end
		S_ST_0: begin
			nextstate = S_ST_1;
			o_mem_wr=1;
			mem_mux_sel=0;
		end
		S_ST_1: begin
		end
		S_MVHI: begin
			alu_mux_a_sel=1;
			alu_mux_b_sel=3;
			rf_w_addr=ir_out[7:5];
			rf_write_en=1;
			rf_only_high=1;
		end
		S_J_X: begin
			pc_mux_sel = ir_out[4]? 0 : 1;
		end
		S_JZ_X: begin
			if(z)
				pc_mux_sel = ir_out[4]? 0 : 1;
		end
		S_JN_X: begin
			if(n)
				pc_mux_sel = ir_out[4]? 0 : 1;
		end
		S_CALL_X: begin
			pc_mux_sel = ir_out[4]? 0 : 1;
			alu_mux_a_sel=1;
			alu_mux_b_sel=2;
			rf_write_en=1;
			rf_w_addr=7;
		end
	endcase 

end

endmodule // control