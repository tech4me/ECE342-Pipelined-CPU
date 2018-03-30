`include "op.svh"
module seq_detect(
    input [15:0] o_mem_data_in_rf_read_stage,
    input [15:0] i_ir_out_in_execute_stage,
    input [15:0] i_ir_out_in_writeback_stage,
    input [15:0] i_alu_reg_in_writeback_stage,
    output logic [1:0]detect_reg_in_rf_read_stage,
    output logic [1:0]detect_reg_in_execute_stage,
    output [15:0] i_alu_reg_from_writeback_stage_in_execute_stage,
    output [15:0] i_alu_reg_from_writeback_stage_in_rf_read_stage
);

//`include "op.sv"
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
assign i_alu_reg_from_writeback_stage_in_execute_stage = (i_ir_out_in_execute_stage[3:0]==OP_MVHI)? {8'd0, i_alu_reg_in_writeback_stage[7:0]}: i_alu_reg_in_writeback_stage;
assign i_alu_reg_from_writeback_stage_in_rf_read_stage = i_alu_reg_in_writeback_stage;

logic detect_to_be_writeback;
always_comb begin
    case(i_ir_out_in_writeback_stage[3:0])
        OP_MV_X:  detect_to_be_writeback = 1;
        OP_ADD_X: detect_to_be_writeback = 1;
        OP_SUB_X: detect_to_be_writeback = 1;
        OP_LD:    detect_to_be_writeback = 1;
        OP_MVHI:  detect_to_be_writeback = 1;
        default: detect_to_be_writeback = 0;
    endcase
end

//below is for rf_read_stage
sub_detect u_rf_read(
    .detect_to_be_writeback(detect_to_be_writeback),
    .i_ir_out_in_to_be_corrected_stage(o_mem_data_in_rf_read_stage),
    .i_ir_out_in_writeback_stage(i_ir_out_in_writeback_stage),
    .detect_signal(detect_reg_in_rf_read_stage)
);
//belwo is for execute stage
sub_detect u_execute(
    .detect_to_be_writeback(detect_to_be_writeback),
    .i_ir_out_in_to_be_corrected_stage(i_ir_out_in_execute_stage),
    .i_ir_out_in_writeback_stage(i_ir_out_in_writeback_stage),
    .detect_signal(detect_reg_in_execute_stage)
);

endmodule

