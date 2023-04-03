`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/02 18:40:54
// Design Name: 
// Module Name: ImmGen
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


module ImmGen(
    input [31:0]        inst,
    input [2:0]         mode,
    input clk,

    output reg [31:0]   imm 
    );

    always @(posedge clk) begin
        case (mode)
            3'b0:   imm<=0;
            3'b1:   imm<={20*{inst[31]},inst[31:20]} ;                                   //imm[11:0],ADDI
            3'b10:   imm<={27*{1'b0},inst[24:20]};                                        //shamt,SLLI
            3'b11:  imm<={inst[31:12],12*{1'b0}};                                        //imm[31:12],LUI
            3'b100:  imm<={11*{inst[31]},inst[31],inst[19:12],inst[20],inst[30:21],1'b0}; //JAL
            3'b101: imm<={19*{inst[31]},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};   //BEQ
            3'b110: imm<={20*{inst[31],inst[31:25],inst[11:7]}};                         //SB
            default:imm<=0;
        endcase
    end

endmodule
