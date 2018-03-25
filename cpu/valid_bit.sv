module valid_bit (
    input clk,
    input rst,
    input enable,
    input valid_in,
    output logic valid_out
);

always_ff @(posedge clk) begin
    if (rst) begin
        valid_out <= 0; 
    end else if (enable) begin
        valid_out <= valid_in;
    end  
end
    
endmodule