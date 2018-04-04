 module alu (
   /* input clk,
    input reset,
    input inside_reg_enable,*/
    input [15:0] in_a,
    input [15:0] in_b,
    input sub,
    output logic [15:0] alu_out,
    output logic z,
    output logic n
);
/*
logic [7:0] in_a_high8;
logic [7:0] in_b_high8;
logic [8:0] alu_low8;
always_ff @( posedge clk) begin
    if(reset) begin
        in_a_high8 <= 0;
        in_b_high8 <= 0;
        alu_low8 <= 0;
    end
    else if(inside_reg_enable) begin
        alu_low8 = sub? (in_a [7:0] - in_b [7:0]) : (in_a [7:0] + in_b [7:0]);
        in_a_high8 = in_a [15:8];
        in_b_high8 = in_b [15:8];
    end
end

always_comb begin
    if (sub)
        alu_out = {in_a_high8 - in_b_high8 + alu_low8[8], alu_low8[7:0]};
    else
        alu_out = {in_a_high8 + in_b_high8 + alu_low8[8], alu_low8[7:0]};
    z = (alu_out == 0);
    n = alu_out[15];
end
*/


always_comb begin
    if (sub)
        alu_out = in_a - in_b;
    else
        alu_out = in_a + in_b;
    z = (alu_out == 0);
    n = alu_out[15];
end


endmodule