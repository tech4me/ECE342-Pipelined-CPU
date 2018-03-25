module stage_writeback (
    input valid,
    input [15:0] ir,
    input [15:0] alu_reg,
    input [15:0] mem_data,
    input z,
    input n,
	output logic rf_write_en,
    output logic only_high
    output logic [2:0] rf_addr, 
    output [15:0] rf_data,
    output logic pc_enable,
    output [15:0] pc
);
`include "op.vh"

logic rf_mux_sel;
logic [2:0] pc_mux_sel;

assign pc = alu_reg;

always_comb begin
    rf_write_en = 1'b0;
    only_high = 1'b0;
    rf_mux_sel = 1'b0;
    rf_addr = ir[7:5];
    pc_mux_sel = 2;
    pc_enable = 1'b0;
    case(ir[3:0])
        OP_MV_X: begin
            rf_write_en = valid;
        end
        OP_ADD_X: begin
            rf_write_en = valid;
        end
        OP_SUB_X: begin
            rf_write_en = valid;
        end
        OP_CMP_X: begin
            // Do nothing
        end
        OP_LD: begin
            rf_write_en = valid;
            rf_mux_sel = 1'b1;
        end
        OP_ST: begin
            // Do nothing
        end
        OP_MVHI: begin
            only_high = 1'b1;
            rf_write_en = valid;
        end
        OP_J_X: begin
            pc_enable = valid;
            pc_mux_sel = ir[4]? 0 : 1;
        end
        OP_JN_X: begin
            pc_enable = valid;
            if(n)
				pc_mux_sel = ir[4]? 0 : 1;
        end
        OP_JZ_X: begin
            pc_enable = valid;
            if(z)
				pc_mux_sel = ir[4]? 0 : 1;
        end
        OP_CALL_X: begin
            pc_enable = 1'b1;
            pc_mux_sel = ir[4]? 0 : 1;
            rf_write_en = valid;
            rf_addr = 3'd7;
        end
        //default:
	endcase
end

rf_mux u_rf_mux(
    .alu_out      (alu_reg      ),
    .i_mem_rddata (mem_data     ),
    .rf_mux_sel   (rf_mux_out   ),
    .rf_mux_out   (rf_data      )
);

endmodule