`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/04 22:09:11
// Design Name: 
// Module Name: ForwardingUnit
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


module ForwardingUnit(
    input clk,
    input   [4:0]       rs1         ,
    input   [4:0]       rs2         ,
    input   [4:0]       rd_m        ,
    input   [4:0]       rd_w        ,

    input               RegWrite_m  ,
    input               RegWrite_w  ,
    
    output reg [1:0]    afwd        ,
    output reg [1:0]    bfwd        ,
    input               eflush      
    );
    reg RegWrite_n;
    reg [4:0] rd_n;

    always @(posedge clk ) begin
        RegWrite_n<=RegWrite_w;
        rd_n<=rd_w;
    end

    always @(*) begin
            if(rs1==rd_m && RegWrite_m) begin
            afwd=2'b1;
            end
            else begin
            if(rs1==rd_w && RegWrite_w ) begin
                afwd=2'b10;
            end
            else begin
                if(rs1==rd_n && RegWrite_n )begin
                    afwd=2'b11;
                end
                else afwd=2'b0;
            end
            end
            if(rs2==rd_m && RegWrite_m) begin
            bfwd=2'b1;
            end
            else begin
            if(rs2==rd_w && RegWrite_w ) begin
                bfwd=2'b10;
            end
            else begin
                if(rs2==rd_n && RegWrite_n )begin
                    bfwd=2'b11;
                end
                else bfwd=2'b0;                
            end   
            end
    end
endmodule
