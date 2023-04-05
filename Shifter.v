`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/02 20:34:31
// Design Name: 
// Module Name: Shifter
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


module Shifter(
    input [31:0]  a,
    input [4:0]  b,
    input         extn,

    output reg [31:0] lshift_s,
    output reg [31:0] rshift_s
    );
    //lshift_s
    reg [31:0] l_mid;
    reg [31:0] r_mid;

    always @(*) begin
        case (b[2:0])
            3'd0: begin
                l_mid=a;
                r_mid=a;
            end
            3'd1: begin
                l_mid={a[30:0],1'b0};
                r_mid={extn,a[31:1]};
            end
            3'd2: begin
                l_mid={a[29:0],{2{1'b0}}};
                r_mid={{2{extn}},a[31:2]};
            end
            3'd3: begin
                l_mid={a[28:0],{3{1'b0}}};
                r_mid={{3{extn}},a[31:3]};
            end
            3'd4: begin
                l_mid={a[27:0],{4{1'b0}}};
                r_mid={{4{extn}},a[31:4]};
            end
            3'd5: begin
                l_mid={a[26:0],{5{1'b0}}};
                r_mid={{5{extn}},a[31:5]};
            end
            3'd6: begin
                l_mid={a[25:0],{6{1'b0}}};
                r_mid={{6{extn}},a[31:6]};
            end
            3'd7: begin
                l_mid={a[24:0],{7{1'b0}}};
                r_mid={{7{extn}},a[31:7]};
            end
        endcase
        
        case (b[4:3])
            3'd0: begin
                lshift_s=l_mid;
                rshift_s=r_mid;
            end
            3'd1: begin
                lshift_s={l_mid[23:0],{8{1'b0}}};
                rshift_s={{8{extn}},r_mid[31:8]};
            end
            3'd2: begin
                lshift_s={l_mid[15:0],{16{1'b0}}};
                rshift_s={{16{extn}},r_mid[31:16]};
            end
            3'd3: begin
                lshift_s={l_mid[7:0],{24{1'b0}}};
                rshift_s={{24{extn}},r_mid[31:24]};
            end
        endcase
    end
endmodule
