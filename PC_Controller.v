`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/02 21:03:18
// Design Name: 
// Module Name: PCController
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


module PC_Controller(
    input [31:0]        imm     ,
    input [2:0]         zero    ,
    input [2:0]         branch  ,
    input [31:0]        y       ,

    input               pc_load ,
    input [1:0]         PCSrc   ,

    input               clk     ,
    input               rstn    ,

    output reg [31:0]   pc      ,
    output reg [31:0]   npc     
    );

    wire [31:0] tpc;
    wire [31:0] npc1;
    wire [31:0] npc2;

    always @(*) begin
        case (PCSrc)
            2'b0: begin
                if(zero&branch) npc=npc2;
                else npc=npc1;
            end
            2'b1: npc=y;
            2'b10: npc={y[31:1],1'b0};
            default: begin
                if(zero&branch) npc=npc2;
                else npc=npc1;
            end
        endcase
    end

    assign tpc=pc;
    
    Adder32 add1(
        .a      (tpc),
        .b      (32'b100),
        .ci     (1'b0),
        .s      (npc1),
        .co     ()
    );

    Adder32 add2(
        .a      (tpc),
        .b      ({imm[30:0],1'b0}),
        .ci     (1'b0),
        .s      (npc2),
        .co     ()
    );

    always @(posedge clk) begin
        if(!rstn) begin
            pc<=0;
        end
        else if(pc_load) begin
            pc<=npc;
        end
        else begin
            pc<=pc;
        end
    end
endmodule
