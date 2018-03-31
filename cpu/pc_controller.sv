`include "op.svh"
module pc_controller(
    input [15:0] mem_data,
    input forwarding_z,
    input forwarding_n,
    input z,
    input n,
    input [15:0] i_ir_out_in_execute_stage,
    input [15:0] forwarding_reg_A,
    input [15:0] pc_in_plus_2,
    output [15:0] pc_out_for_r7, 
    output logic [15:0] pc_to_be_jumped,
    output logic branch_sig
);
/*
always_comb begin
    case(i_mem_rddata[3:0])
        OP_MV_X:  
        OP_ADD_X:
        OP_SUB_X:
        OP_CMP_X:
        OP_LD:  
        OP_ST:  
        OP_MVHI:
        OP_J_X:
        OP_JN_X:
        OP_JZ_X:
        OP_CALL_X:
        default:
    endcase  
    
end
*/
logic real_z;
logic real_n;

flag_forwarding i_flag_forwarding (
    .forwarding_z             (forwarding_z             ),
    .forwarding_n             (forwarding_n             ),
    .z                        (z                        ),
    .n                        (n                        ),
    .i_ir_out_in_execute_stage(i_ir_out_in_execute_stage),
    .real_z                   (real_z                   ),
    .real_n                   (real_n                   )
);

assign pc_out_for_r7 = pc_in_plus_2;
always_comb begin
    case(mem_data[3:0])
        OP_J_X:begin
                branch_sig = 1'b1;
                if(mem_data[4]) begin
                    pc_to_be_jumped = pc_in_plus_2 + ({{5{mem_data[15]}}, mem_data[15:5]} << 1);
                end
                else begin
                    pc_to_be_jumped = forwarding_reg_A;
                end
                end
        OP_JN_X:begin
                if(mem_data[4]) begin
                    pc_to_be_jumped = pc_in_plus_2 + ({{5{mem_data[15]}}, mem_data[15:5]} << 1);
                end
                else begin
                    pc_to_be_jumped = forwarding_reg_A;
                end

                if(real_n)
                    branch_sig = 1'b1;
                else
                    branch_sig = 0;

                end
        OP_JZ_X:begin
                if(mem_data[4]) begin
                    pc_to_be_jumped = pc_in_plus_2 + ({{5{mem_data[15]}}, mem_data[15:5]} << 1);
                end
                else begin
                    pc_to_be_jumped = forwarding_reg_A;
                end

                if(real_z)
                    branch_sig = 1'b1;
                else
                    branch_sig = 0;

                end
        OP_CALL_X:begin
                branch_sig = 1'b1;
                if(mem_data[4]) begin
                    pc_to_be_jumped = pc_in_plus_2 + ({{5{mem_data[15]}}, mem_data[15:5]} << 1);
                end
                else begin
                    pc_to_be_jumped = forwarding_reg_A;
                end
                end
        default:begin
                    branch_sig = 0;
                    pc_to_be_jumped = pc_in_plus_2;
                end
    endcase
end


endmodule

module flag_forwarding(
    input forwarding_z,
    input forwarding_n,
    input z,
    input n,
    input [15:0] i_ir_out_in_execute_stage,
    output logic real_z,
    output logic real_n
);
always_comb begin
    case(i_ir_out_in_execute_stage[3:0])
        OP_ADD_X: begin 
                    real_z = forwarding_z;
                    real_n = forwarding_n;
                  end
        OP_SUB_X: begin 
                    real_z = forwarding_z;
                    real_n = forwarding_n;
                  end
        OP_CMP_X: begin 
                    real_z = forwarding_z;
                    real_n = forwarding_n;
                  end
        default: begin 
                    real_z = z;
                    real_n = n;
                 end
    endcase  
end
endmodule // flag_forwarding
