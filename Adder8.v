`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/02 18:58:06
// Design Name: 
// Module Name: Adder8
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Adder8(
    input   [7:0] a,b,
    input         ci,
    output  [7:0] s,
    output        co
    );

        wire    [7:0] C;
        wire    [7:0] G;
        wire    [7:0] P;

        assign  G = a & b;
        assign  P = a ^ b;

        genvar j1;
        genvar j2;
        generate
            for(j1 = 0; j1 < 8; j1 = j1 + 1) begin: BLOCK1
                wire [j1 : 0] mid;                //连接线
                for(j2 = j1; j2 > 0; j2 = j2 - 1) begin: BLOCK2
                    assign mid[j2] = ( & P[j1 : j2] ) && G[j2-1];
                end
                assign mid[0] = ( & P[j1 : 0] ) && ci;
                assign C[j1] = ( | mid ) || G[j1];
            end
        endgenerate

        assign  s[0] = P[0] ^ ci;
        genvar  i;
        generate
            for(i = 0; i < 7; i = i + 1) begin: BLOCK3
                assign  s[i+1] = P[i+1] ^ C[i];
            end
        endgenerate
        assign  co   = C[7];
endmodule
