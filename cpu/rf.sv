module rf(
	input clk,
	input rst,
	input [2:0]addr, 
	input [15:0] data_in,
	input [2:0]rf_addr_A,
	input [2:0]rf_addr_B,
	input only_high,
	input write_en,
	output [15:0]rf_out_A,
	output [15:0]rf_out_B,
	output [7:0][15:0]rf
	);
logic [7:0]rf_load;
decoder decode_dut(
	.addr(addr),
	.addr_de(rf_load)	
	);
logic [7:0][15:0] regfile;

assign rf = regfile;

genvar i;
generate 
	for (i=0;i<8;i++) begin: regfileloop
		always_ff @(posedge clk) begin
			if(rst) begin
				regfile[i] <= 0;
			end else begin
				if(rf_load[i]&write_en)
					regfile[i]<=only_high? {data_in[15:8],regfile[i][7:0]} : data_in;
			end
		end
	end
endgenerate

inside_rf_mux inside_A(
	.regfile(regfile[0:7]),
	.rf_addr(rf_addr_A),
	.rf_out(rf_out_A)
	);
inside_rf_mux inside_B(
	.regfile(regfile[0:7]),
	.rf_addr(rf_addr_B),
	.rf_out(rf_out_B)
	);

endmodule // rf

module inside_rf_mux(
	input [7:0][15:0]regfile,
	input [2:0]rf_addr,
	output logic [15:0]rf_out
	);
always_comb begin
	case(rf_addr)
		3'd0:rf_out = regfile[0]; 
		3'd1:rf_out = regfile[1];
		3'd2:rf_out = regfile[2];
		3'd3:rf_out = regfile[3];
		3'd4:rf_out = regfile[4];
		3'd5:rf_out = regfile[5];
		3'd6:rf_out = regfile[6];
		3'd7:rf_out = regfile[7];
		default:rf_out = 16'd0;	
	endcase // rf_addr
end
endmodule


module decoder(
	input [2:0]addr,
	output [7:0] addr_de
	);

assign addr_de[0]=(~addr[0])&(~addr[1])&(~addr[2]);
assign addr_de[1]=(addr[0])&(~addr[1])&(~addr[2]);
assign addr_de[2]=(~addr[0])&(addr[1])&(~addr[2]);
assign addr_de[3]=(addr[0])&(addr[1])&(~addr[2]);
assign addr_de[4]=(~addr[0])&(~addr[1])&(addr[2]);
assign addr_de[5]=(addr[0])&(~addr[1])&(addr[2]);
assign addr_de[6]=(~addr[0])&(addr[1])&(addr[2]);
assign addr_de[7]=(addr[0])&(addr[1])&(addr[2]);

endmodule // decoder