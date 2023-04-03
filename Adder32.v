`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/02 18:58:24
// Design Name: 
// Module Name: Adder32
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


module Adder32(
    input   [31:0] a,b,
    input         ci,
    output  [31:0] s,
    output        co
    );

    //中间进位
    wire c_mid1;
    wire c_mid2;
    wire c_mid3;

    Adder8 add1(
        .a      (a[7:0]),
        .b      (b[7:0]),
        .ci     (ci),
        .s      (s[7:0]),
        .co     (c_mid1)
    );

    Adder8 add2(
        .a      (a[15:8]),
        .b      (b[15:8]),
        .ci     (c_mid1),
        .s      (s[15:8]),
        .co     (c_mid2)
    );

    Adder8 add3(
        .a      (a[23:16]),
        .b      (b[23:16]),
        .ci     (c_mid2),
        .s      (s[23:16]),
        .co     (c_mid3)
    );

    Adder8 add4(
        .a      (a[31:24]),
        .b      (b[31:24]),
        .ci     (c_mid3),
        .s      (s[31:24]),
        .co     (co)
    );
endmodule
