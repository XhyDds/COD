`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/04 23:11:03
// Design Name: 
// Module Name: HarzardUnit
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


module HarzardUnit(
    input [4:0] rs1     ,
    input [4:0] rs2     ,
    input [4:0] rd      ,
    input       MemRead ,

    output reg  eflush  ,
    output reg  dstall  ,
    output reg  fstall  
    );

    always @(*) begin
        if(MemRead && (rs1==rd || rs2==rd)) begin   //不会死循环，因为eflush清空了MemRead
            eflush=1;
            dstall=1;
            fstall=1;
        end
        else begin
            eflush=0;
            dstall=0;
            fstall=0;
        end
    end
endmodule
