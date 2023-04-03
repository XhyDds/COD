`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/02 19:10:58
// Design Name: 
// Module Name: Suber
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


module Suber(
    input   [31:0] a,b,
    output  [31:0] s
    );

    wire [31:0] s_mid;

    Adder32 add(
        .a      (a),
        .b      (~b),
        .ci     (1'b1),
        .s      (s),
        .co     ()
    );

endmodule
