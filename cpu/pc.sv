module pc (
    input clk,
    input rst,
    input [15:0] pc_mux_out_in,
    input inc,
    output logic [15:0] pc_out
);

always_ff @(posedge clk) begin
    if(rst)
        pc_out <= 16'b0;
    else
        pc_out <= (inc) ? (pc_out + 2) : (pc_mux_out_in);
end

endmodule