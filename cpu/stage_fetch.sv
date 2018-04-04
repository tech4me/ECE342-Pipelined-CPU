module stage_fetch(
    input valid_in,
    input [15:0] pc_out,
    input set_invalid_sig_to_fetch,
    output [15:0]o_pc_addr,
    output o_pc_rd,
    output valid_out,
    output pc_fetch_inc,
    output pc_fetch_en
);
assign valid_out = set_invalid_sig_to_fetch? 0 : valid_in;
assign o_pc_rd = valid_in;
assign o_pc_addr[15:1] = pc_out[15:1];
assign o_pc_addr[0] = 0;
assign pc_fetch_en = valid_in;
assign pc_fetch_inc = 1'b1;

endmodule


