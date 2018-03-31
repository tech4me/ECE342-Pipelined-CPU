module pc (
    input clk,
    input rst,
    input [15:0] pc_to_be_jumped,
    //input inc,
    input enable,
    input branch_sig,
    output logic [15:0] pc_out
);

always_ff @(posedge clk) begin
    if(rst)
        pc_out <= 16'b0;
    else if(enable)
        pc_out <= (branch_sig) ? pc_to_be_jumped : (pc_out + 2);
end

endmodule