`include "op.svh"
module sub_detect_br(
    input detect_to_be_writeback,
    input [15:0]i_ir_out_in_to_be_corrected_stage,
    input [15:0]i_ir_out_in_execute_stage,
    output logic [1:0] detect_signal
);
//`include "op.sv"
logic r7_from_call_is_to_be_writen;
assign r7_from_call_is_to_be_writen = (i_ir_out_in_execute_stage[3:0] == OP_CALL_X);
always_comb begin
    if(detect_to_be_writeback) begin
        case(i_ir_out_in_to_be_corrected_stage[3:0])
            OP_J_X:   begin
                            if(~(i_ir_out_in_to_be_corrected_stage[4])&& ( (i_ir_out_in_to_be_corrected_stage[7:5]==i_ir_out_in_execute_stage[7:5]) 
                        || (r7_from_call_is_to_be_writen && (i_ir_out_in_to_be_corrected_stage[7:5]==3'b111)) ) )
                            detect_signal[0] = 1'b1;
                        else
                            detect_signal[0] = 0;
                        end
            OP_JN_X:  begin
                            if(~(i_ir_out_in_to_be_corrected_stage[4])&& ( (i_ir_out_in_to_be_corrected_stage[7:5]==i_ir_out_in_execute_stage[7:5]) 
                        || (r7_from_call_is_to_be_writen && (i_ir_out_in_to_be_corrected_stage[7:5]==3'b111)) ) )
                            detect_signal[0] = 1'b1;
                        else
                            detect_signal[0] = 0;
                        end 
            OP_JZ_X:  begin
                            if(~(i_ir_out_in_to_be_corrected_stage[4])&&( (i_ir_out_in_to_be_corrected_stage[7:5]==i_ir_out_in_execute_stage[7:5]) 
                        || (r7_from_call_is_to_be_writen && (i_ir_out_in_to_be_corrected_stage[7:5]==3'b111)) ) )
                            detect_signal[0] = 1'b1;
                        else
                            detect_signal[0] = 0;
                        end
            OP_CALL_X:begin
                            if(~(i_ir_out_in_to_be_corrected_stage[4])&&( (i_ir_out_in_to_be_corrected_stage[7:5]==i_ir_out_in_execute_stage[7:5]) 
                        || (r7_from_call_is_to_be_writen && (i_ir_out_in_to_be_corrected_stage[7:5]==3'b111)) ) )
                            detect_signal[0] = 1'b1;
                        else
                            detect_signal[0] = 0;
                        end
            default: detect_signal[0] = 0;
        endcase
    end
    else
        detect_signal[0] = 0; 
end

assign detect_signal[1] = 0;  

endmodule
