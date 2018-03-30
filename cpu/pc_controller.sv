`include "op.svh"
module pc_controller(
    input [15:0] mem_data,
    input forwarding_z,
    input forwarding_n,
    input [15:0] pc_in_plus_2,
    output [15:0] pc_out_r7, 
    output logic [15:0] pc_to_be_jumped,
    output logic branch_sig
);
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
assign pc_out_r7 = pc_in_plus_2;
always_comb begin
    
end


endmodule
