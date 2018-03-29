module _16bit_reg (
    input clk,
    input rst,
    input enable,
    input [15:0] reg_in,
    output logic [15:0] reg_out
);

always_ff @(posedge clk) begin
    if (rst) begin
        reg_out <= 0; 
    end else if (enable) begin
        reg_out <= reg_in;
    end  
end
    
endmodule