module sub_detect(
    input detect_to_be_writeback,
    input [15:0]i_ir_out_in_to_be_corrected_stage,
    input [15:0]i_ir_out_in_writeback_stage,
    output logic [1:0] detect_signal
);
`include "op.vh"
always_comb begin
    if(detect_to_be_writeback) begin
        case(i_ir_out_in_to_be_corrected_stage[3:0])
            OP_MV_X: 
                    detect_signal[0] = 0;
            OP_ADD_X:begin
                        if((i_ir_out_in_to_be_corrected_stage[7:5]==i_ir_out_in_writeback_stage[7:5]))
                            detect_signal[0] = 1'b1;
                        else
                            detect_signal[0] = 0;
                     end
            OP_SUB_X:begin
                        if((i_ir_out_in_to_be_corrected_stage[7:5]==i_ir_out_in_writeback_stage[7:5]))
                            detect_signal[0] = 1'b1;
                        else
                            detect_signal[0] = 0;
                     end
            OP_CMP_X: begin
                        if((i_ir_out_in_to_be_corrected_stage[7:5]==i_ir_out_in_writeback_stage[7:5]))
                            detect_signal[0] = 1'b1;
                        else
                            detect_signal[0] = 0;
                     end
            OP_LD:   
                    detect_signal[0] = 0;
                     
            OP_ST:    begin
                        if(i_ir_out_in_to_be_corrected_stage[7:5]==i_ir_out_in_writeback_stage[7:5])
                            detect_signal[0] = 1'b1;
                        else
                            detect_signal[0] = 0;
                     end
            OP_MVHI: detect_signal[0] = 1;
            /*OP_J_X: 
            OP_JN_X:   
            OP_JZ_X:  
            OP_CALL_X:*/
            default: detect_signal[0] = 0;
        endcase
    end
    else
        detect_signal[0] = 0; 
end


always_comb begin
    if(detect_to_be_writeback) begin
        case(i_ir_out_in_to_be_corrected_stage[3:0])
            OP_MV_X: begin
                        if(  (~i_ir_out_in_to_be_corrected_stage[4])&&(i_ir_out_in_to_be_corrected_stage[10:8]==i_ir_out_in_writeback_stage[7:5]) )
                            detect_signal[1] = 1'b1;
                        else
                            detect_signal[1] = 0;
                     end
            OP_ADD_X:begin
                        if((~i_ir_out_in_to_be_corrected_stage[4])&&(i_ir_out_in_to_be_corrected_stage[10:8]==i_ir_out_in_writeback_stage[7:5]))
                            detect_signal[1] = 1'b1;
                        else
                            detect_signal[1] = 0;
                     end
            OP_SUB_X:begin
                        if((~i_ir_out_in_to_be_corrected_stage[4])&&(i_ir_out_in_to_be_corrected_stage[10:8]==i_ir_out_in_writeback_stage[7:5]))
                            detect_signal[1] = 1'b1;
                        else
                            detect_signal[1] = 0;
                     end
            OP_CMP_X: begin
                        if((~i_ir_out_in_to_be_corrected_stage[4])&&(i_ir_out_in_to_be_corrected_stage[10:8]==i_ir_out_in_writeback_stage[7:5]))
                            detect_signal[1] = 1'b1;
                        else
                            detect_signal[1] = 0;
                     end
            OP_LD:   begin
                        if(  i_ir_out_in_to_be_corrected_stage[10:8]==i_ir_out_in_writeback_stage[7:5] )
                            detect_signal[1] = 1'b1;
                        else
                            detect_signal[1] = 0;
                     end
            OP_ST:    begin
                        if(  i_ir_out_in_to_be_corrected_stage[10:8]==i_ir_out_in_writeback_stage[7:5] )
                            detect_signal[1] = 1'b1;
                        else
                            detect_signal[1] = 0;
                     end
            OP_MVHI: detect_signal[1] = 0;
            /*OP_J_X: 
            OP_JN_X:   
            OP_JZ_X:  
            OP_CALL_X:*/
            default: detect_signal[1] = 0;
        endcase
    end
    else
        detect_signal[1] = 0; 
end

endmodule
