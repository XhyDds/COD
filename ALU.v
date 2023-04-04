`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/02 18:03:06
// Design Name: 
// Module Name: ALU
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


module ALU(
    input   [31:0]      a0      ,
    input   [31:0]      b0      ,
    input   [31:0]      imm     ,
    input   [31:0]      pc      ,
    input   [1:0]       ALUSrc1 ,   //B
    input   [1:0]       ALUSrc2 ,   //A
    input   [2:0]       ALUOP   ,
    input               sp_sign ,
    input               uors    ,

    output reg [31:0]   result  ,
    output     [2:0]    zero    
    );

    parameter ADD      = 3'b000;
    parameter SUB      = 3'b000;
    parameter SLL      = 3'b001;
    parameter SLT      = 3'b010;
    parameter SLTU     = 3'b011;
    parameter XOR      = 3'b100;
    parameter SRL      = 3'b101;
    parameter OR       = 3'b110;
    parameter AND      = 3'b111;

    reg extn;

    reg [31:0] b;
    reg [31:0] a;

    wire [31:0] add_s;
    wire [31:0] sub_s;          //a-b
    wire [2:0]  sr;
    wire [2:0]  ur; 
    wire [31:0] lshift_s;
    wire [31:0] rshift_s;

    Adder32 add(
        .a      (a),
        .b      (b),
        .ci     (1'b0),
        .s      (add_s),
        .co     ()
    );

    Suber sub(
        .a      (a),
        .b      (b),
        .s      (sub_s)
    );

    Comparer comparer(
        .a      (a),
        .b      (b),
        .ur     (ur),
        .sr     (sr)
    );

    Shifter Shifter(
        .a      (a),
        .b      (b[4:0]),
        .extn   (extn),

        .lshift_s(lshift_s),
        .rshift_s(rshift_s)
    );

    assign zero=uors?ur:sr;

    always @(*) begin
        //oprand
        case (ALUSrc1)
            2'b0: b<=b0;
            2'b1: b<=imm;
            2'b10:b<=32'b100; 
            default: b<=b0;
        endcase
        case (ALUSrc2)
            2'b0: a<=a0;
            2'b1: a<=pc;
            2'b10:a<=32'b0; 
            default: a<=a0;
        endcase

        //oprate
        case (ALUOP)
            ADD : begin
                if(sp_sign) result=sub_s;
                else result=add_s;
            end
            // SLL :   result=lshift_s;
            SLL :   result=a<<2;
            SLT :   result=sr[2];
            SLTU:   result=ur[2];
            XOR :   result=a^b;
            SRL :   begin
                if(sp_sign) begin
                    extn=a[31];
                    result=rshift_s;
                end
                else begin
                    extn=1'b0;
                    result=rshift_s;
                end
            end
            OR  :   result=a|b;
            AND :   result=a&b;
            default: result=0;
        endcase
    end
endmodule
