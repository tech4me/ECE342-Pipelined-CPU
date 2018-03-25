 module alu (
    input [15:0] in_a,
    input [15:0] in_b,
    input sub,
    output logic [15:0] alu_out,
    output logic z,
    output logic n
);

always_comb begin
    if (sub)
        alu_out = in_a - in_b;
    else
        alu_out = in_a + in_b;
    z = (alu_out == 0);
    n = alu_out[15];
end

endmodule