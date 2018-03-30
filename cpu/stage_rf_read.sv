module stage_rf_read (
    input valid_in,
    input [15:0] mem_data,
    input [15:0] rf_A,
    input [15:0] rf_B,
    output valid_out,
    output ir_enable,
    output [15:0] ir,
    output [2:0]rf_sel_A,
    output [2:0]rf_sel_B,
    output reg_A_en,
    output reg_B_en
    output [15:0] reg_A,
    output [15:0] reg_B
);

assign valid_out = valid_in;
assign ir_enable = valid_in;

assign ir = mem_data;

assign rf_sel_A = mem_data[7:5];
assign rf_sel_B = mem_data[10:8];

assign reg_A_en = valid_in;
assign reg_B_en = valid_in;

logic [1:0] alu_mux_a_sel;
logic [2:0] alu_mux_b_sel;

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
                    if(mem_data[4])
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
    case(mem_data[3:0])
        OP_MV_X:  alu_mux_b_sel=ir_in_execute[4] ? 0 : 1;
        OP_ADD_X: alu_mux_b_sel=ir_in_execute[4] ? 0 : 1;
        OP_SUB_X: alu_mux_b_sel=ir_in_execute[4] ? 0 : 1;
        OP_CMP_X: alu_mux_b_sel=ir_in_execute[4] ? 0 : 1;
        OP_MVHI:  alu_mux_b_sel=3;
        OP_LD: alu_mux_b_sel=1;
        OP_ST: alu_mux_b_sel=1;
        OP_CALL_X:alu_mux_b_sel=2;
        default: begin 
                    alu_mux_b_sel = 0;
                 end
    endcase
end


alu_mux u_alu_mux(
	.rf_out_A      (rf_A),
	.ir_out_imm8   (mem_data[15:8]  ),
    .ir_out_imm11  (mem_data[15:5]  ),
	.rf_out_B      (rf_B),
	.pc_out        (16'd127       ),//not implemented
	.alu_mux_a_sel (alu_mux_a_sel ),
	.alu_mux_b_sel (alu_mux_b_sel ),
	.alu_mux_A_out (reg_A ),
	.alu_mux_B_out (reg_B )
);

endmodule
