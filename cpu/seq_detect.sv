`include "op.svh"
module seq_detect(
    input clk,
    input rst,
    input [15:0] o_mem_data_in_rf_read_stage,
    input [15:0] i_ir_out_in_execute_stage,// o_rf_read
    input [15:0] o_ir_out_in_execute_stage,
    input [15:0] i_ir_out_in_writeback_stage,
    input [15:0] i_alu_reg_in_writeback_stage,
    input [15:0] o_alu_out_in_execute_stage,//alse used for branching

    //for branch in rf_read
    input [15:0] real_i_ir_out_in_execute_stage,


    output logic [1:0]detect_reg_in_rf_read_stage,
    output logic [1:0]detect_reg_in_execute_stage,
    output logic [15:0] i_alu_reg_from_writeback_stage_in_execute_stage,
    output [15:0] i_alu_reg_from_writeback_stage_in_rf_read_stage,

    //for LD and ST in rf_read stage
    output logic [1:0] detect_reg_in_rf_read_stage_ld_st,
    output logic [15:0] i_alu_reg_from_writeback_stage_in_rf_read_stage_ld_st
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
//assign i_alu_reg_from_writeback_stage_in_execute_stage = (i_ir_out_in_execute_stage[3:0]==OP_MVHI)? {8'd0, i_alu_reg_in_writeback_stage[7:0]}: i_alu_reg_in_writeback_stage;
logic [1:0] sub_detect_reg_in_execute_stage;
always_ff @(posedge clk) begin
    if(rst) begin
        i_alu_reg_from_writeback_stage_in_execute_stage <=0;
        detect_reg_in_execute_stage <= 0;     
    end
    else begin
        i_alu_reg_from_writeback_stage_in_execute_stage = (i_ir_out_in_execute_stage[3:0]==OP_MVHI)? {8'd0, o_alu_out_in_execute_stage[7:0]}: o_alu_out_in_execute_stage;
        detect_reg_in_execute_stage<=sub_detect_reg_in_execute_stage;
    end
end

//assign i_alu_reg_from_writeback_stage_in_rf_read_stage = i_alu_reg_in_writeback_stage;

logic detect_to_be_writeback_for_execute_stage;
always_comb begin
    case(o_ir_out_in_execute_stage[3:0])
        OP_MV_X:  detect_to_be_writeback_for_execute_stage = 1;
        OP_ADD_X: detect_to_be_writeback_for_execute_stage = 1;
        OP_SUB_X: detect_to_be_writeback_for_execute_stage = 1;
        OP_LD:    detect_to_be_writeback_for_execute_stage = 1;
        OP_MVHI:  detect_to_be_writeback_for_execute_stage = 1;
        OP_CALL_X: detect_to_be_writeback_for_execute_stage = 1;
        default: detect_to_be_writeback_for_execute_stage = 0;
    endcase
end


logic detect_to_be_writeback;
always_comb begin
    case(i_ir_out_in_writeback_stage[3:0])
        OP_MV_X:  detect_to_be_writeback = 1;
        OP_ADD_X: detect_to_be_writeback = 1;
        OP_SUB_X: detect_to_be_writeback = 1;
        OP_LD:    detect_to_be_writeback = 1;
        OP_MVHI:  detect_to_be_writeback = 1;
        OP_CALL_X: detect_to_be_writeback = 1;
        default: detect_to_be_writeback = 0;
    endcase
end

//below is for rf_read_stage
logic [1:0]detect_reg_in_rf_read_stage_not_br;
sub_detect u_rf_read(
    .detect_to_be_writeback(detect_to_be_writeback),
    .i_ir_out_in_to_be_corrected_stage(o_mem_data_in_rf_read_stage),
    .i_ir_out_in_writeback_stage(i_ir_out_in_writeback_stage),
    .detect_signal(detect_reg_in_rf_read_stage_not_br)
);
//belwo is for execute stage
sub_detect u_execute(
    .detect_to_be_writeback(detect_to_be_writeback_for_execute_stage),
    .i_ir_out_in_to_be_corrected_stage(i_ir_out_in_execute_stage),
    .i_ir_out_in_writeback_stage(o_ir_out_in_execute_stage),
    .detect_signal(sub_detect_reg_in_execute_stage)
);



//for branching

//first check in execute stage, any reg will be writeback in next stage?
logic detect_to_be_writeback_br;
always_comb begin
    case(real_i_ir_out_in_execute_stage[3:0])
        OP_MV_X:  detect_to_be_writeback_br = 1;
        OP_ADD_X: detect_to_be_writeback_br = 1;
        OP_SUB_X: detect_to_be_writeback_br = 1;
        OP_LD:    detect_to_be_writeback_br = 1;
        OP_MVHI:  detect_to_be_writeback_br = 1;
        OP_CALL_X: detect_to_be_writeback_br = 1;
        default: detect_to_be_writeback_br = 0;
    endcase
end

//next sub_detect to determine raise flag or not
logic [1:0] detect_reg_in_rf_read_stage_br;
sub_detect_br u_sub_detect_br(
	.detect_to_be_writeback            (detect_to_be_writeback_br            ),
    .i_ir_out_in_to_be_corrected_stage (o_mem_data_in_rf_read_stage ),
    .i_ir_out_in_execute_stage       (real_i_ir_out_in_execute_stage       ),
    .detect_signal                     (detect_reg_in_rf_read_stage_br                     )
);
//priority higher of execute than writeback
assign i_alu_reg_from_writeback_stage_in_rf_read_stage = (detect_reg_in_rf_read_stage_br[0])? o_alu_out_in_execute_stage : i_alu_reg_in_writeback_stage;
assign detect_reg_in_rf_read_stage = (detect_reg_in_rf_read_stage_br[0])? detect_reg_in_rf_read_stage_br : detect_reg_in_rf_read_stage_not_br;

//for LD and ST in rf_read stage

//first now raise flag if to be writeback in execute stage
logic detect_to_be_writeback_ld_st;
always_comb begin
    case(real_i_ir_out_in_execute_stage[3:0])
        OP_MV_X:  detect_to_be_writeback_ld_st = 1;
        OP_ADD_X: detect_to_be_writeback_ld_st = 1;
        OP_SUB_X: detect_to_be_writeback_ld_st = 1;
        OP_LD:    detect_to_be_writeback_ld_st = 1;
        OP_MVHI:  detect_to_be_writeback_ld_st = 1;
        OP_CALL_X: detect_to_be_writeback_ld_st = 1;
        default: detect_to_be_writeback_ld_st = 0;
    endcase
end

//next detect there is LD or ST instr in rf_read stage
sub_detect_ld_st u_sub_detect_ld_st(
	.detect_to_be_writeback            (detect_to_be_writeback_ld_st            ),
    .i_ir_out_in_to_be_corrected_stage (o_mem_data_in_rf_read_stage ),
    .i_ir_out_in_execute_stage       (real_i_ir_out_in_execute_stage       ),
    .detect_signal                     (detect_reg_in_rf_read_stage_ld_st                     )
);

assign i_alu_reg_from_writeback_stage_in_rf_read_stage_ld_st = o_alu_out_in_execute_stage;

endmodule

