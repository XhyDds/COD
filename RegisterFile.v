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

        output  [31:0]    rd0,rd1         //读数据
    );

    reg [31:0] rf [0:31];                    //寄存器堆

    initial begin
                //$readmemh("memory.list",rf);
        rf[ 0]=32'h0000;
        rf[ 1]=32'h0000;
        rf[ 2]=32'h0000;
        rf[ 3]=32'h0000;
        rf[ 4]=32'h0000;
        rf[ 5]=32'h0000;
        rf[ 6]=32'h0000;
        rf[ 7]=32'h0000;
        rf[ 8]=32'h0000;
        rf[ 9]=32'h0000;
        rf[10]=32'h0000;
        rf[11]=32'h0000;
        rf[12]=32'h0000;
        rf[13]=32'h0000;
        rf[14]=32'h0000;
        rf[15]=32'h0000;
        rf[16]=32'h0000;
        rf[17]=32'h0000;
        rf[18]=32'h0000;
        rf[19]=32'h0000;
        rf[20]=32'h0000;
        rf[21]=32'h0000;
        rf[22]=32'h0000;
        rf[23]=32'h0000;
        rf[24]=32'h0000;
        rf[25]=32'h0000;
        rf[26]=32'h0000;
        rf[27]=32'h0000;
        rf[28]=32'h0000;
        rf[29]=32'h0000;
        rf[30]=32'h0000;
        rf[31]=32'h0000;
    end
    assign    rd0=rf[ra0];
    assign    rd1=rf[ra1];

    always @(posedge clk) begin
        if(we) rf[wa] <= wd;                 //写
    end 
endmodule
