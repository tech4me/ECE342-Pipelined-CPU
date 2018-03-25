`ifndef _op_vh_
`define _op_vh_
localparam
OP_MV_X  = 4'b0000,
OP_ADD_X = 4'b0001,
OP_SUB_X = 4'b0010,
OP_CMP_X = 4'b0011,
OP_LD    = 4'b0100,
OP_ST    = 4'b0101,
OP_MVHI  = 4'b0110,
OP_J_X   = 4'b1000,
OP_JZ_X  = 4'b1001,
OP_JN_X  = 4'b1010,
OP_CALL_X= 4'b1100;
`endif