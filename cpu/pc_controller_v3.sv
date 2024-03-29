`include "op.svh"
module pc_controller_v3(
    input clk,
    input reset,
    input [15:0] i_pc_out_in_fetch_stage,
    input [15:0] i_ir_out_in_execute_stage,
    input [15:0] i_ir_out_in_writeback_stage,
    input [15:0] real_RA,

    input [15:0] i_alu_out_in_writeback_stage,// in execute stage: Rx in branching instr

    input valid_in_fetch_stage,
    input valid_in_rf_read_stage,
    input valid_in_execute_stage,
    input [15:0] mem_data,
    input z,
    input n,

    output branch_sig,
    output [15:0] pc_in_br,
    output set_invalid_sig_to_fetch,
    output set_invalid_sig_to_rf_read
);

/**************************************here to do seq_detect for modify remove "alu_execute to pc_control"***************/

logic detect_to_be_writeback_br_new;
always_comb begin
    case(i_ir_out_in_writeback_stage[3:0])
        OP_MV_X:  detect_to_be_writeback_br_new = 1;
        OP_ADD_X: detect_to_be_writeback_br_new = 1;
        OP_SUB_X: detect_to_be_writeback_br_new = 1;
        OP_LD:    detect_to_be_writeback_br_new = 1;
        OP_MVHI:  detect_to_be_writeback_br_new = 1;
        OP_CALL_X: detect_to_be_writeback_br_new = 1;
        default: detect_to_be_writeback_br_new = 0;
    endcase
end


logic [1:0] detect_reg_in_rf_read_stage_br_new;
sub_detect_br u_sub_detect_br(
	.detect_to_be_writeback            (detect_to_be_writeback_br_new            ),
    .i_ir_out_in_to_be_corrected_stage (i_ir_out_in_execute_stage ),
    .i_ir_out_in_execute_stage       (i_ir_out_in_writeback_stage       ),
    .detect_signal                     (detect_reg_in_rf_read_stage_br_new                     )
);

/**************************************here to do seq_detect for modify remove "alu_execute to pc_control"***************/

//for slave input
logic [15:0] prediction_pc;
logic prediction_sig;

logic is_branch_instr_or_not_in_rf_read_stage;//set in rf_read stage
logic is_branch_instr_or_not_reg_in_execute_stage;

logic actual_jump_or_not;//set in execute stage

//fetch stage
logic [15:0] original_pc_fetch;// for rf_read stage

logic [15:0] pc_in_from_fetch_stage;
logic [15:0] pc_in_reg_from_fetch_stage_to_rf_read_stage;

logic branch_sig_reg_from_fetch_stage_to_rf_read_stage;
logic branch_sig_from_fetch_stage;

//here is to test without prediction case
//assign pc_in_from_fetch_stage = i_pc_out_in_fetch_stage+2;
//assign branch_sig_from_fetch_stage = 0;

assign pc_in_from_fetch_stage = prediction_pc;
assign branch_sig_from_fetch_stage = prediction_sig;


always_ff @( posedge clk ) begin
    if(reset) begin
        branch_sig_reg_from_fetch_stage_to_rf_read_stage <= 0;
        pc_in_reg_from_fetch_stage_to_rf_read_stage <= 0;
        original_pc_fetch <= 0;
    end
    else if(valid_in_fetch_stage) begin
        branch_sig_reg_from_fetch_stage_to_rf_read_stage <= branch_sig_from_fetch_stage;
        pc_in_reg_from_fetch_stage_to_rf_read_stage <= pc_in_from_fetch_stage;
        original_pc_fetch <= i_pc_out_in_fetch_stage;
    end
end

//rf_read_stage
logic [15:0 ]original_pc_rf_read; // for execute stage 
logic branch_sig_reg_from_rf_read_stage_to_execute_stage;
//logic [15:0] mem_data_reg_from_rf_read_stage_to_execute_stage;
logic correct_branch_sig_from_fetch_stage_checked_in_rf_read_stage;
logic uncondition_br_valid;
logic uncondition_br_valid_reg;
logic [15:0] pc_in_from_rf_read_stage;
always_comb begin
    case(mem_data[3:0])
        OP_J_X: begin
            is_branch_instr_or_not_in_rf_read_stage = 1;
                end
        OP_JN_X:begin
            is_branch_instr_or_not_in_rf_read_stage = 1;
                end
        OP_JZ_X:begin
            is_branch_instr_or_not_in_rf_read_stage = 1;
                end
        OP_CALL_X:begin
            is_branch_instr_or_not_in_rf_read_stage = 1;
                end
        default: is_branch_instr_or_not_in_rf_read_stage = 0;
    endcase  
end
always_comb begin
    case(mem_data[3:0])
        OP_J_X: begin 
                if(mem_data[4]) begin
                    uncondition_br_valid = 1;
                end
                else begin
                    uncondition_br_valid = 0;
                end
                end
        OP_CALL_X:begin 
                if(mem_data[4]) begin
                    uncondition_br_valid = 1;
                end
                else begin
                    uncondition_br_valid = 0;
                end
                end
        default: uncondition_br_valid = 0;
    endcase  
end

assign correct_branch_sig_from_fetch_stage_checked_in_rf_read_stage = (~uncondition_br_valid) || 
    (
    (uncondition_br_valid && branch_sig_reg_from_fetch_stage_to_rf_read_stage)  
    &&(pc_in_reg_from_fetch_stage_to_rf_read_stage == pc_in_from_rf_read_stage)
    );
assign  pc_in_from_rf_read_stage = original_pc_fetch + 2'd2 + ({{5{mem_data[15]}}, mem_data[15:5]} << 1);
/*always_comb begin
    case(mem_data[3:0])
        OP_J_X: begin
                    if(mem_data[4]) begin
                        pc_in_from_rf_read_stage = original_pc_fetch + 2'd2 + ({{5{mem_data[15]}}, mem_data[15:5]} << 1);
                    end
                    else 
                    pc_in_from_rf_read_stage = pc_in_reg_from_fetch_stage_to_rf_read_stage;
                end
        OP_CALL_X:begin
                    if(mem_data[4]) begin
                        pc_in_from_rf_read_stage = original_pc_fetch + 2'd2 + ({{5{mem_data[15]}}, mem_data[15:5]} << 1);
                    end
                    else 
                    pc_in_from_rf_read_stage = pc_in_reg_from_fetch_stage_to_rf_read_stage;
                end
        default: pc_in_from_rf_read_stage = pc_in_reg_from_fetch_stage_to_rf_read_stage;
    endcase  
end
*/
logic [15:0] forwarding_reg_A_reg;
logic [15:0] pc_in_from_rf_read_stage_to_execute_stage_for_compare;
logic [15:0] pre_compute_pc;

always_ff @(posedge clk) begin
    if(reset) begin
       // mem_data_reg_from_rf_read_stage_to_execute_stage <= 0;
        original_pc_rf_read <= 0;
        uncondition_br_valid_reg <= 0;
        branch_sig_reg_from_rf_read_stage_to_execute_stage <= 0;
        is_branch_instr_or_not_reg_in_execute_stage <= 0;
        forwarding_reg_A_reg <= 0;
        pc_in_from_rf_read_stage_to_execute_stage_for_compare <= 0;
        pre_compute_pc <= 0;
    end
    else if(valid_in_rf_read_stage) begin
      //  mem_data_reg_from_rf_read_stage_to_execute_stage <= mem_data;
        original_pc_rf_read <= original_pc_fetch;
        uncondition_br_valid_reg <=uncondition_br_valid;
        branch_sig_reg_from_rf_read_stage_to_execute_stage <= branch_sig_reg_from_fetch_stage_to_rf_read_stage;
        is_branch_instr_or_not_reg_in_execute_stage<= is_branch_instr_or_not_in_rf_read_stage;
        forwarding_reg_A_reg <= real_RA;
        pc_in_from_rf_read_stage_to_execute_stage_for_compare <= pc_in_reg_from_fetch_stage_to_rf_read_stage;
        pre_compute_pc <= pc_in_from_rf_read_stage;
    end
end

//execute stage
logic valid_in_cycle_3;
logic correct_branch_sig_from_fetch_stage_checked_in_execute_stage;
logic [15:0] pc_in_from_execute_stage;

assign valid_in_cycle_3 = (~uncondition_br_valid_reg);

always_comb begin
        case(i_ir_out_in_execute_stage[3:0])
            OP_J_X: begin
                        actual_jump_or_not = 1;
                    end
            OP_JN_X: begin
                        if(n) begin
                            actual_jump_or_not = 1;
                        end
                        else begin
                            actual_jump_or_not = 0;
                        end    
                    end
            OP_JZ_X:begin
                        if(z) begin
                            actual_jump_or_not = 1;
                        end
                        else begin
                            actual_jump_or_not = 0;
                        end    
                    end
            OP_CALL_X:begin
                        actual_jump_or_not = 1;
                      end
            default:actual_jump_or_not = 0;
        endcase  
end

assign correct_branch_sig_from_fetch_stage_checked_in_execute_stage = (~(actual_jump_or_not ^ branch_sig_reg_from_rf_read_stage_to_execute_stage))
    &&
    (pc_in_from_rf_read_stage_to_execute_stage_for_compare == pc_in_from_execute_stage);


//write this first, if critical path is not changed, then change it.
always_comb begin
    case(i_ir_out_in_execute_stage[3:0])
        OP_J_X: begin
                    if(i_ir_out_in_execute_stage[4]) begin
                        pc_in_from_execute_stage = pre_compute_pc;
                    end
                    else 
                    pc_in_from_execute_stage = detect_reg_in_rf_read_stage_br_new[0]? i_alu_out_in_writeback_stage :forwarding_reg_A_reg;
                end
        OP_JN_X:begin
                    if(i_ir_out_in_execute_stage[4]) begin
                        if(n)
                        pc_in_from_execute_stage = pre_compute_pc;
                        else
                        pc_in_from_execute_stage = original_pc_rf_read + 2'd2;
                    end
                    else begin
                    if(n)
                    pc_in_from_execute_stage = detect_reg_in_rf_read_stage_br_new[0]? i_alu_out_in_writeback_stage :forwarding_reg_A_reg;
                    else
                    pc_in_from_execute_stage = original_pc_rf_read + 2'd2;
                    end
                end
        OP_JZ_X:begin
                    if(i_ir_out_in_execute_stage[4]) begin
                        if(z)
                        pc_in_from_execute_stage = pre_compute_pc;
                        else
                        pc_in_from_execute_stage = original_pc_rf_read + 2'd2;
                    end
                    else begin
                    if(z)
                    pc_in_from_execute_stage = detect_reg_in_rf_read_stage_br_new[0]? i_alu_out_in_writeback_stage :forwarding_reg_A_reg;
                    else
                    pc_in_from_execute_stage = original_pc_rf_read + 2'd2;
                    end
                end
        OP_CALL_X:begin
                    if(i_ir_out_in_execute_stage[4]) begin
                        pc_in_from_execute_stage = pre_compute_pc;
                    end
                    else 
                    pc_in_from_execute_stage = detect_reg_in_rf_read_stage_br_new[0]? i_alu_out_in_writeback_stage :forwarding_reg_A_reg;
                end
        default: pc_in_from_execute_stage = original_pc_rf_read + 2'd2;
    endcase  
end

//here call br_prediciton module
branch_predictor u_branch_predictor(
	.clk           (clk           ),
    .rst           (reset           ),
    .valid_rf_read (valid_in_rf_read_stage ),
    .valid_execute (valid_in_execute_stage ),
    .current_pc    (i_pc_out_in_fetch_stage    ),
    .is_pc_jump    (is_branch_instr_or_not_in_rf_read_stage   ),
    .jump          (actual_jump_or_not          ),
    .target_pc     (pc_in_from_execute_stage     ),
    .prediction    (prediction_sig    ),
    .prediction_pc (prediction_pc )
);


//here call br_sel_control module

br_sel_controller u_br_sel_controller(
    .valid_in_rf_read_stage(valid_in_rf_read_stage),
    .valid_in_execute_stage(valid_in_execute_stage),
    .is_branch_instr_or_not_in_rf_read_stage(is_branch_instr_or_not_in_rf_read_stage),
    .is_branch_instr_or_not_reg_in_execute_stage (is_branch_instr_or_not_reg_in_execute_stage),
	.branch_sig_from_fetch_stage                                  (branch_sig_from_fetch_stage                                  ),
    .pc_in_from_fetch_stage                                       (pc_in_from_fetch_stage                                       ),
    .correct_branch_sig_from_fetch_stage_checked_in_rf_read_stage (correct_branch_sig_from_fetch_stage_checked_in_rf_read_stage ),
    .uncondition_br_valid                                         (uncondition_br_valid                                         ),
    .pc_in_from_rf_read_stage                                     (pc_in_from_rf_read_stage                                     ),
    .valid_in_cycle_3                                             (valid_in_cycle_3                                             ),
    .correct_branch_sig_from_fetch_stage_checked_in_execute_stage (correct_branch_sig_from_fetch_stage_checked_in_execute_stage ),
    .pc_in_from_execute_stage                                     (pc_in_from_execute_stage                                     ),
    .actual_jump_or_not                                           (actual_jump_or_not                                           ),
    .branch_sig                                                   (branch_sig                                                   ),
    .pc_in_br                                                     (pc_in_br                                                     ),
    .set_invalid_sig_to_fetch                                     (set_invalid_sig_to_fetch                                     ),
    .set_invalid_sig_to_rf_read                                   (set_invalid_sig_to_rf_read                                   )
);


endmodule

module br_sel_controller(
    input valid_in_rf_read_stage,
    input valid_in_execute_stage,
    input is_branch_instr_or_not_in_rf_read_stage,
    input is_branch_instr_or_not_reg_in_execute_stage,

    input branch_sig_from_fetch_stage,
    input [15:0] pc_in_from_fetch_stage,

    input correct_branch_sig_from_fetch_stage_checked_in_rf_read_stage,
    input uncondition_br_valid,//branch_sig_in_rf_read
    input [15:0] pc_in_from_rf_read_stage,

    input valid_in_cycle_3,
    input correct_branch_sig_from_fetch_stage_checked_in_execute_stage,
    input [15:0] pc_in_from_execute_stage,
    input actual_jump_or_not,//branch_sig_in_execute

    output logic branch_sig,
    output logic [15:0] pc_in_br,
    output logic set_invalid_sig_to_fetch,
    output logic set_invalid_sig_to_rf_read
);

always_comb begin
    if(valid_in_cycle_3 & (~correct_branch_sig_from_fetch_stage_checked_in_execute_stage) & valid_in_execute_stage &is_branch_instr_or_not_reg_in_execute_stage) begin
        branch_sig = actual_jump_or_not;
        pc_in_br = pc_in_from_execute_stage;
        set_invalid_sig_to_fetch = 1;
        set_invalid_sig_to_rf_read = 1;
    end
    else if( (~correct_branch_sig_from_fetch_stage_checked_in_rf_read_stage) & valid_in_rf_read_stage &is_branch_instr_or_not_in_rf_read_stage) begin
        branch_sig = uncondition_br_valid;
        pc_in_br = pc_in_from_rf_read_stage;
        set_invalid_sig_to_fetch = 1;
        set_invalid_sig_to_rf_read = 0;
    end
    else begin
        branch_sig = branch_sig_from_fetch_stage;
        pc_in_br = pc_in_from_fetch_stage;
        set_invalid_sig_to_fetch = 0;
        set_invalid_sig_to_rf_read = 0;
    end    
end

endmodule
