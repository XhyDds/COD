`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/03 10:32:37
// Design Name: 
// Module Name: EXTer
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


module EXTer(
    input  [31:0]       originword,
    input  [2:0]        mode,
    output reg [31:0]   extword
    );

    always @(*) begin
        case (mode)
            3'b000: extword=originword;
            3'b001: begin
                if(originword[7])  extword={24'hffffff,originword[7:0]};
                else               extword={24'h000000,originword[7:0]};
            end
            3'b010: extword={24*{1'b0},originword[7:0]};
            3'b011: begin
                if(originword[15]) extword={16'hffff,originword[15:0]};
                else               extword={16'h0000,originword[15:0]};
            end 
            3'b100: extword={16*{1'b0},originword[15:0]};
            default: extword=originword;
        endcase
    end
endmodule
