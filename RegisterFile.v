`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/02 20:57:34
// Design Name: 
// Module Name: RegisterFile
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

//同步寄存器堆
module RegisterFile(
        input                clk,            //时钟
        input [4:0]          ra0,ra1,        //读地址
        input [4:0]          wa,             //写地址
        input [31:0]         wd,             //写数据
        input                we,             //写使能

        output reg [31:0]    rd0,rd1         //读数据
    );

    reg [31:0] rf [0:31];                    //寄存器堆

    always @(posedge clk) begin
        rd0<=rf[ra0];
        rd1<=rf[ra1];
        if(we) rf[wa] <= wd;                 //写
    end 
endmodule
