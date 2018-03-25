module stage_rf_read (
    input valid_in,
    input [15:0] mem_data,
    output valid_out,
    output ir_enable,
    output [15:0] ir,
    output [2:0]rf_sel_A,
    output [2:0]rf_sel_B
);

assign valid_out = valid_in;
assign ir_enable = valid_in;

assign ir = mem_data;

assign rf_sel_A = mem_data[7:5];
assign rf_sel_B = mem_data[10:8];

endmodule