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

//pc同步更新器
//尚未传出flush信号
module PC_Controller(
    input [31:0]        imm     ,
    input [31:0]        pc_d    ,
    input [2:0]         zero    ,
    input [2:0]         branch  ,
    input [31:0]        y       ,

    input               clk     ,
    input               rstn    ,

    output reg [31:0]   pc      ,
    output reg [31:0]   npc     ,

    output reg          flush   ,
    input               fstall  ,
    input               stop    
    );

    wire [31:0] tpc;
    wire [31:0] npc1;
    wire [31:0] npc2_0;
    wire  [31:0] npc2;

    // always @(posedge clk) begin
    //     npc2<=npc2_0;
    // end

    always @(*) begin
        if(stop) begin
            npc=tpc;
        end
        if(zero&branch) begin
            npc=npc2;    
            flush=1;        //  不会死循环，因为flush后必然无法进入该分支（且保证了pc更新）
        end    
        else begin
            if(fstall) begin
                npc=tpc;
            end
            else begin
                npc=npc1;
            end
            flush=0;
        end 
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
        .a      (pc_d),
        .b      (imm[31:0]),
        .ci     (1'b0),
        .s      (npc2),
        .co     ()
    );

    always @(posedge clk) begin
        if(!rstn) begin
            pc<=0;
        end
        // else if(pc_load) begin
        //     pc<=npc;
        // end
        // else begin
        //     pc<=pc;
        // end
        else begin
            pc<=npc;
        end
    end
endmodule
