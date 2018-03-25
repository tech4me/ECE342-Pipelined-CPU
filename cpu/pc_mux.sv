module pc_mux (
    input [10:0] ir_out_in,
    input [15:0] rf_out_in,
    input [15:0] pc_out_in,
    input [1:0] pc_mux_sel,
    output logic [15:0] pc_mux_out
);

always_comb begin
    case(pc_mux_sel)
        0:
            pc_mux_out = pc_out_in + ({{5{ir_out_in[10]}}, ir_out_in} << 1);
        1:
            pc_mux_out = rf_out_in;
        2:
            pc_mux_out = pc_out_in;
        default:
            pc_mux_out = 16'b0;
    endcase
end

endmodule