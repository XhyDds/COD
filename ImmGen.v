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

    wire a;
    assign a=inst[31];

    always @(*) begin
        case (mode)
            3'b0:   imm=32'b0;
            3'b1:   begin                                                               //imm[11:0],ADDI
                imm={{20{inst[31]}},inst[31:20]} ;     
            end 
            3'b10:  imm={{27{1'b0}},inst[24:20]};                                        //shamt,SLLI
            3'b11:  imm={inst[31:12],{12{1'b0}}};                                        //imm[31:12],LUI
            3'b100: begin                                                               //JAL
                imm={{11{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0};
            end 
            3'b101: begin                                                               //BEQ
                imm={{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};   
            end 
            3'b110: begin                     //SB
                imm={{20{inst[31]}},inst[31:25],inst[11:7]};  
            end
            default:imm=32'b0;
        endcase
    end

endmodule
