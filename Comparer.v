`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/03 12:01:47
// Design Name: 
// Module Name: Comparer
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


module Comparer(
    input [31:0]        a,
    input [31:0]        b,

    output [2:0]        ur,
    output [2:0]        sr
    );

    wire [31:0]         s;
    wire               co;

    reg         ug;
    reg         ul;
    reg         sg;
    reg         sl;
    
    Adder32  adder(
        .a             (a),
        .b             (~b),
        .ci            (1'b1),
        .s             (s),
        .co            (co)
        
    );

    always @(*) begin
        if(!s) begin
            {ug,ul,sg,sl}=4'b0000;
        end
        else begin
            if(co)
                {ug,ul}=2'b10;
            else
                {ug,ul}=2'b01;
            case({a[31],b[31]})
            2'b00:         {sg,sl}={ug,ul};
            2'b01:         {sg,sl}=2'b10;
            2'b10:         {sg,sl}=2'b01;
            2'b11:         {sg,sl}={ug,ul};
            endcase
        end
    end

    assign ur={ul,ul|ug,ug};
    assign sr={sl,sl|sg,sg};
    
endmodule
