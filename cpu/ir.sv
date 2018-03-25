module ir (
    input clk,
    input rst,
    input ir_enable,
    input [15:0] ir_in,
    output logic [15:0] ir_out
);

always_ff @(posedge clk) begin
    if (rst) begin
        ir_out <= 0; 
    end else if (ir_enable) begin
        ir_out <= ir_in;
    end  
end
    
endmodule