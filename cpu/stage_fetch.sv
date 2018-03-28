module stage_fetch(
    input valid_in,
    input [15:0] pc_out,
    output [15:0]o_pc_addr,
    output o_pc_rd,
    output valid_out,
    output pc_fetch_en
);
assign valid_out = valid_in;
assign o_pc_rd = valid_in;
assign o_pc_addr[15:1] = pc_out[15:1];
assign o_pc_addr[0] = 0;
assign pc_fetch_en = valid_in;

endmodule


